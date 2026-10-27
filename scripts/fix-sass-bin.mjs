/**
 * npm may hoist optional `sass` and link `node_modules/.bin/sass` to its JS shim;
 * Hugo needs the sass-embedded Dart binary (embedded protocol). Remove hoisted
 * `sass` and relink bins from sass-embedded when present.
 */
import { existsSync, rmSync } from 'node:fs';
import { execSync } from 'node:child_process';

if (existsSync('node_modules/sass')) {
  rmSync('node_modules/sass', { recursive: true, force: true });
  execSync('npm rebuild sass-embedded', { stdio: 'inherit' });
}
