---
name: update-deps
description: Update all renovate-annotated dependency versions in the Dockerfile by querying upstream for each latest release, edit the pinned versions in place, commit, then hand off to /open-pr. Use when the user asks to "update deps", "bump deps", "update dockerfile deps", or refresh image dependencies on-demand (out-of-band from Renovate).
---

# Update Dockerfile dependencies

On-demand bumping of every pinned version in `Dockerfile`. Mirrors what Renovate would eventually produce, but interactive and immediate.

## When to use

- User asks to update deps, bump deps, update dockerfile deps, or refresh image dependencies.
- A specific tool needs to be bumped right now and waiting for Renovate is not acceptable.

## When NOT to use

- Updating Drupal / Composer / Vortex packages. Use the dedicated `/update-drupal`, `/update-vortex`, or Composer-related skills.
- Editing `versions-config.json` or `goss.yaml`. Both track runtime detection; neither pins versions.
- The user wants README package versions refreshed. That happens automatically via `.github/workflows/update-readme.yml` after merge.

## Pre-flight

1. Confirm clean working tree: `git status --porcelain` must be empty.
2. Confirm branch. If on `main`, `master`, or `develop`, create `feature/update-deps-YYMMDD` (today's date, e.g. `feature/update-deps-260521`).
3. Confirm these CLIs are on `$PATH`: `gh`, `jq`, `npm`, `curl`, `docker`. If any are missing, stop and ask the user how to proceed.

## Step 1 - Discover entries

Read `Dockerfile`. Find every block matching the Renovate custom-manager regex from `renovate.json`:

```
#\s*renovate:\s*datasource=(?<datasource>\S+)\s+depName=(?<depName>\S+)(?:\s+versioning=(?<versioning>\S+))?(?:\s+extractVersion=(?<extractVersion>\S+))?\s*\n(?:.*\n)*?.*?(?:ENV|ARG|RUN)\s+.*?version=(?<currentValue>[^\s&]+)
```

For each match, record:

- `datasource`
- `depName`
- `versioning` (optional)
- `extractVersion` (optional)
- `currentValue`
- `lineNumber` of the `version=` literal (this is the line you will edit)

Also capture the base image digest pin from the `FROM` line:

- Pattern: `FROM php:8.4-cli-bookworm@sha256:<digest>`
- This is a `docker` datasource entry. There are two `FROM` lines (builder + final). Both must be updated to the same new digest.

## Step 2 - Resolve latest per datasource

Make one Bash call per command (no piping, no `&&` chaining). Save intermediate output to files under `.artifacts/tmp/` if you need to process it further with `jq` or similar.

### `github-releases`

1. `gh api repos/<depName>/releases/latest --jq .tag_name` returns e.g. `v0.11.0` or `43`.
2. Strip a leading `v` if present, since the Dockerfile stores the bare value.
3. If `extractVersion` is something other than `^(?<version>.*)$`, apply the regex literally to the tag name.
4. If `gh` is unauthenticated and rate-limited, fall back to `curl -fsSL https://api.github.com/repos/<depName>/releases/latest -o .artifacts/tmp/<depName>.json` and parse `.tag_name` with `jq`.

### `npm`

1. `npm view <depName> version` returns the latest semver string. No `v` prefix.

### `node` (with `versioning=node`)

1. `curl -fsSL https://nodejs.org/dist/index.json -o .artifacts/tmp/node-index.json`
2. `jq -r '[.[] | select(.lts != false)][0].version' .artifacts/tmp/node-index.json` returns the latest LTS, e.g. `v24.15.0`.
3. Strip the leading `v` per `extractVersion=^v(?<version>.*)$`.

### `docker` (base image)

1. `docker buildx imagetools inspect php:8.4-cli-bookworm --format "{{.Manifest.Digest}}"` returns `sha256:<digest>`.
2. If `buildx` is unavailable, fall back to:
   - `docker pull php:8.4-cli-bookworm`
   - `docker inspect --format "{{index .RepoDigests 0}}" php:8.4-cli-bookworm` and strip the `php@` prefix to get `sha256:<digest>`.

If any resolver fails for a single dependency, record it as `error` in the diff table and continue with the others. Do not abort the whole run on a single resolver failure.

## Step 3 - Print the diff

Render a markdown table to the chat so the user can see what is about to change:

```
| Dependency      | Datasource      | Current   | Latest    | Status     |
|-----------------|-----------------|-----------|-----------|------------|
| kcov            | github-releases | 43        | 44        | bump       |
| shellcheck      | github-releases | 0.11.0    | 0.11.0    | up-to-date |
| php (base)      | docker          | sha256:ca | sha256:7f | bump       |
```

If there is nothing to bump, stop here, report "All dependencies are up to date.", and do not commit or push.

## Step 4 - Apply edits

For every `bump` row, use the `Edit` tool on `Dockerfile`:

- Include enough surrounding context in `old_string` so the replacement is unambiguous. Anchoring on the preceding `# renovate:` comment line is the safest pattern when `version=<value>` is not unique across the file.
- Replace only the `<value>` after `version=`. Do not reformat other lines.

For the base image bump, replace the `@sha256:<old>` digest across both `FROM` lines. Use `replace_all: true` since the digest substring is unique to the base image.

After every edit, re-read the affected lines to confirm the change landed correctly.

## Step 5 - Commit and hand off

1. `git add Dockerfile`
2. `git commit -m "Updated Docker image dependencies."`
3. Invoke the `/open-pr` skill. Never call `gh pr create` directly.

## Notes

- `goss.yaml` asserts presence and output of commands, not numeric versions, so it does not need updates here.
- `versions-config.json` is consumed by `versions.js` for README rendering. Leave it alone.
- The README "Included packages" section is regenerated post-merge by `.github/workflows/update-readme.yml`.
- Yarn is intentionally pinned to v1.x (classic). `npm view yarn version` returns the latest 1.x because Yarn Berry is published as `@yarnpkg/cli`, not `yarn`.
- Verification is intentionally not part of this skill. CI (`.github/workflows/test.yml`) builds the image and runs `dgoss` on the PR.
