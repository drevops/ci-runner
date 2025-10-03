#!/usr/bin/env node

const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

const configPath = path.join(__dirname, 'versions-config.json');
const toolsConfig = JSON.parse(fs.readFileSync(configPath, 'utf-8'));

const tools = toolsConfig.map(tool => ({
  ...tool,
  versionRegex: new RegExp(tool.regex, 'im')
}));

function extractVersion(output, regex) {
  const match = output.match(regex);
  return match ? match[1] : 'unknown';
}

function getToolVersion(dockerImage, tool) {
  try {
    const output = execSync(
      `docker run --rm --platform linux/amd64 "${dockerImage}" ${tool.cmd} 2>&1`,
      { encoding: 'utf-8' }
    );
    return extractVersion(output, tool.versionRegex);
  } catch (error) {
    const output = error.stdout || '';
    return extractVersion(output, tool.versionRegex);
  }
}

function generateMarkdown(dockerImage, sectionTitle) {
  let markdown = `${sectionTitle}\n\n`;

  for (const tool of tools) {
    const version = getToolVersion(dockerImage, tool);
    markdown += `- [${tool.name}](${tool.url}): \`${version}\`\n`;
  }

  return markdown;
}

function updateReadme(readmePath, sectionTitle, newContent) {
  const readme = fs.readFileSync(readmePath, 'utf-8');
  const lines = readme.split('\n');
  const result = [];
  let shouldSkip = false;

  for (const line of lines) {
    if (line === sectionTitle) {
      result.push(newContent.trimEnd());
      shouldSkip = true;
      continue;
    }

    if (shouldSkip && line.match(/^##\s/)) {
      shouldSkip = false;
    }

    if (!shouldSkip) {
      result.push(line);
    }
  }

  const newReadme = result.join('\n') + "\n\n";

  if (readme === newReadme) {
    return false;
  }

  fs.writeFileSync(readmePath, newReadme);
  return true;
}

const args = process.argv.slice(2);
let dockerImage, shouldUpdateReadme = false, readmePath, sectionTitle = '## Included packages';

for (let i = 0; i < args.length; i++) {
  if (args[i] === '--update-readme') {
    shouldUpdateReadme = true;
    readmePath = args[i + 1] || 'README.md';
    i++;
  } else if (args[i] === '--section') {
    sectionTitle = args[i + 1];
    i++;
  } else if (!dockerImage) {
    dockerImage = args[i];
  }
}

if (!dockerImage) {
  console.error('Usage: node versions.js <docker-image> [--update-readme [readme-path]] [--section "## Section Title"]');
  process.exit(1);
}

const markdown = generateMarkdown(dockerImage, sectionTitle);

if (shouldUpdateReadme) {
  const hasChanged = updateReadme(readmePath, sectionTitle, markdown);
  if (hasChanged) {
    console.log(`${readmePath} updated with new package versions`);
    process.exit(1);
  } else {
    console.log(`${readmePath} is already up to date`);
    process.exit(0);
  }
} else {
  console.log(markdown);
}
