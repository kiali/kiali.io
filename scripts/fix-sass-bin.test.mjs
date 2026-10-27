import { execFileSync } from 'node:child_process';
import { test } from 'node:test';
import { join } from 'node:path';

const root = join(import.meta.dirname, '..');

test('fix-sass-bin.mjs exits successfully when sass is not hoisted', () => {
  execFileSync('node', ['scripts/fix-sass-bin.mjs'], { cwd: root, stdio: 'pipe' });
});
