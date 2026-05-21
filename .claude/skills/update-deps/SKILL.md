---
name: update-deps
description: Check the latest upstream version for every renovate-annotated dependency in the Dockerfile, then rewrite the pinned version literals in place. Use when the user asks to "update deps", "bump deps", "update dockerfile deps", or refresh image dependencies. Git operations are out of scope.
---

# Update Dockerfile dependencies

Scan `Dockerfile`, resolve each renovate-annotated dependency's latest upstream version, and rewrite the pinned `version=...` literal in place. The skill stops after the file edits. Branching, committing, and PR creation are not part of this skill.

## When to use

- User asks to update deps, bump deps, update dockerfile deps, or refresh image dependencies.

## When NOT to use

- Updating Drupal / Composer / Vortex packages. Use the dedicated `/update-drupal`, `/update-vortex`, or Composer-related skills.
- Editing `versions-config.json` or `goss.yaml`. Both track runtime detection; neither pins versions.

## Step 1 - Discover entries

Read `Dockerfile`. Find every block matching the Renovate custom-manager regex from `renovate.json`:

```regex
#\s*renovate:\s*datasource=(?<datasource>\S+)\s+depName=(?<depName>\S+)(?:\s+versioning=(?<versioning>\S+))?(?:\s+extractVersion=(?<extractVersion>\S+))?\s*\n(?:.*\n)*?.*?(?:ENV|ARG|RUN)\s+.*?version=(?<currentValue>[^\s&]+)
```

For each match, record `{datasource, depName, versioning, extractVersion, currentValue, lineNumber}`.

Also capture the base image digest pin from the two `FROM` lines (builder + final):

- Pattern: `FROM php:8.4-cli-bookworm@sha256:<digest>`
- Datasource is `docker`. Both `FROM` lines must end up with the same new digest.

## Step 2 - Resolve latest per datasource

Make one Bash call per command. Do not chain with `&&`, do not pipe with `|`; the global hook blocks both. If a step needs JSON processing, save the response to `.artifacts/tmp/` first, then run `jq` against the file in a separate call.

If any single resolver fails, record the dep as `error` and continue. Do not abort the whole run.

### `github-releases`

1. `gh api repos/<depName>/releases/latest --jq .tag_name` returns e.g. `v0.11.0`, `43`, or `docker-v29.5.2`.
2. If the API returns 404 (no releases published, only tags), fall back to `gh api repos/<depName>/tags --jq ".[0].name"`.
3. Normalize the tag to a bare version: strip any leading `v` and any non-semver prefix such as `docker-v` (moby/moby uses this).
4. If `extractVersion` is something other than `^(?<version>.*)$`, apply that regex literally to the tag instead.

### `npm`

1. `npm view <depName> version` returns the latest semver, no prefix.

### `node` (with `versioning=node`)

1. `curl -fsSL https://nodejs.org/dist/index.json -o .artifacts/tmp/node-index.json`
2. `jq -r 'map(select(.lts != false))[0].version' .artifacts/tmp/node-index.json` returns the latest LTS, e.g. `v24.15.0`. The filter is intentionally pipe-free.
3. Strip the leading `v`.

### `docker` (base image)

1. `docker buildx imagetools inspect php:8.4-cli-bookworm --raw` prints the raw index JSON to stdout; redirect with `> .artifacts/tmp/php-index.json` is fine because it is a redirection, not a pipe.
2. `jq -r ".manifests[0].digest" .artifacts/tmp/php-index.json` is one option, but the value the Dockerfile pins is the index digest, not a per-arch manifest digest. The simplest reliable command is `docker manifest inspect --verbose php:8.4-cli-bookworm` and read the top-level `Digest` field for the named tag.
3. Fallback: `docker pull php:8.4-cli-bookworm`, then `docker inspect --format "{{index .RepoDigests 0}}" php:8.4-cli-bookworm`, then strip the `php@` prefix.

## Step 3 - Print the diff

Render a markdown table so the user sees exactly what will change:

```markdown
| Dependency      | Datasource      | Current   | Latest    | Status     |
|-----------------|-----------------|-----------|-----------|------------|
| kcov            | github-releases | 43        | 43        | up-to-date |
| docker (moby)   | github-releases | 28.5.2    | 29.5.2    | bump       |
| php (base)      | docker          | sha256:ca | sha256:7f | bump       |
```

If nothing is behind, stop here and report "All dependencies are up to date.". Do not touch `Dockerfile`.

## Step 4 - Edit the Dockerfile

For every `bump` row, use the `Edit` tool on `Dockerfile`:

- Include the preceding `# renovate: ...` comment line in `old_string` so the replacement is unambiguous when `version=<value>` is not unique on its own.
- Replace only the `<value>` after `version=`. Do not reformat surrounding lines.

For the base image bump, replace the `@sha256:<old>` substring with `@sha256:<new>` using `replace_all: true` (the digest substring is unique to the base image, so this safely covers both `FROM` lines).

After each edit, re-read the affected line to confirm the change landed correctly.

The skill ends here. Do not stage, commit, or push.

## Notes

- `goss.yaml` and `versions-config.json` do not pin versions and are not touched.
- README's "Included packages" section is regenerated post-merge by `.github/workflows/update-readme.yml`.
- Yarn is intentionally pinned to v1.x (classic). `npm view yarn version` returns the latest 1.x; Yarn Berry is published as `@yarnpkg/cli`.
