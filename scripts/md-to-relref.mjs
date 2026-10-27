/**
 * Convert internal root-relative Markdown/HTML links to Hugo relref shortcodes.
 * Skips external URLs. Resolves /docs/... against content/en/docs/ on disk.
 */
import { readFileSync, writeFileSync, readdirSync, statSync } from 'node:fs';
import { dirname, join, relative, resolve } from 'node:path';

const CONTENT_EN = resolve('content/en');
const DOCS_ROOT = join(CONTENT_EN, 'docs');

const SECTION_BY_LOWER = new Map(
  readdirSync(DOCS_ROOT, { withFileTypes: true })
    .filter((e) => e.isDirectory())
    .map((e) => [e.name.toLowerCase(), e.name]),
);

function walk(dir, files = []) {
  for (const name of readdirSync(dir)) {
    const path = join(dir, name);
    if (statSync(path).isDirectory()) {
      walk(path, files);
    } else if (/\.(md|html)$/.test(name)) {
      files.push(path);
    }
  }
  return files;
}

function resolveSegment(parentDir, segment) {
  if (!segment || segment === '.') return parentDir;
  if (segment === '..') return dirname(parentDir);
  let entries;
  try {
    entries = readdirSync(parentDir);
  } catch {
    return null;
  }
  const lower = segment.toLowerCase();
  for (const name of entries) {
    if (name.toLowerCase() === lower) {
      return join(parentDir, name);
    }
  }
  return join(parentDir, segment);
}

function resolvePathSegments(baseDir, segments) {
  let dir = baseDir;
  for (const seg of segments) {
    if (!seg) continue;
    dir = resolveSegment(dir, seg);
    if (dir === null) return null;
  }
  return dir;
}

function findPagePath(resolved) {
  if (!resolved) {
    return null;
  }
  if (resolved.endsWith('.md') && statSync(resolved).isFile()) {
    return resolved;
  }
  const asFile = `${resolved}.md`;
  try {
    statSync(asFile);
    return asFile;
  } catch {
    const index = join(resolved, '_index.md');
    try {
      statSync(index);
      return index;
    } catch {
      return null;
    }
  }
}

function splitUrl(url) {
  const hash = url.indexOf('#');
  if (hash === -1) {
    return { pathPart: url, fragment: '' };
  }
  return {
    pathPart: url.slice(0, hash),
    fragment: url.slice(hash),
  };
}

function urlToTargetFile(urlPath) {
  const { pathPart, fragment } = splitUrl(urlPath);
  let path = pathPart.replace(/^\/+/, '').replace(/\/+$/, '');
  const parts = path.split('/').filter(Boolean);

  if (parts[0] === 'en') {
    parts.shift();
  }

  let base;
  let rest;
  if (parts[0] === 'docs') {
    base = DOCS_ROOT;
    rest = parts.slice(1);
  } else if (parts.length === 0) {
    return { file: null, fragment };
  } else {
    base = CONTENT_EN;
    rest = parts;
  }

  if (rest.length === 0) {
    const index = join(base, '_index.md');
    return { file: findPagePath(index) ?? findPagePath(base), fragment };
  }

  if (base === CONTENT_EN && rest.length === 1) {
    const file = findPagePath(resolvePathSegments(base, rest));
    if (file) {
      return { file, fragment };
    }
  }

  const mapped = rest.map((seg, i) => {
    if (base === DOCS_ROOT && i === 0) {
      return SECTION_BY_LOWER.get(seg.toLowerCase()) ?? seg;
    }
    return seg;
  });

  const file = findPagePath(resolvePathSegments(base, mapped));
  return { file, fragment };
}

function fileToRelrefPath(fromFile, targetFile) {
  let target = targetFile;
  if (target.endsWith('_index.md')) {
    target = dirname(target);
  } else if (target.endsWith('.md')) {
    target = target.slice(0, -3);
  }
  let rel = relative(dirname(fromFile), target).replace(/\\/g, '/');
  if (rel === '') {
    rel = '.';
  } else if (!rel.startsWith('.')) {
    rel = `./${rel}`;
  }
  return rel;
}

function toRelref(fromFile, url) {
  const { file, fragment } = urlToTargetFile(url);
  if (!file) {
    return null;
  }
  return fileToRelrefPath(fromFile, file) + fragment;
}

const mdLinkPattern = /\[([^\]]*)\]\((\/(?:docs|community|news)\/[^)\s]+)\)/g;
const hrefPattern = /href="(\/(?:docs|community|news)\/[^"]+)"/g;

let converted = 0;
let skipped = 0;

for (const file of walk(CONTENT_EN)) {
  let text = readFileSync(file, 'utf8');
  let changed = false;

  text = text.replace(mdLinkPattern, (match, label, url) => {
    const rel = toRelref(file, url);
    if (!rel) {
      skipped += 1;
      return match;
    }
    converted += 1;
    changed = true;
    return `[${label}]({{< relref "${rel}" >}})`;
  });

  text = text.replace(hrefPattern, (match, url) => {
    const rel = toRelref(file, url);
    if (!rel) {
      skipped += 1;
      return match;
    }
    converted += 1;
    changed = true;
    return `href="{{ relref . \"${rel}\" }}"`;
  });

  if (changed) {
    writeFileSync(file, text);
  }
}

console.log(`Converted ${converted} link(s) to relref.`);
if (skipped) {
  console.log(`Skipped ${skipped} (unresolved).`);
  process.exitCode = 1;
}
