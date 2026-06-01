#!/usr/bin/env node
// Patcht ckstats-Quellcode um NULL-Werte von bchpool abzufangen
const fs = require('fs');

// --- Patch 1: utils/helpers.ts ---
// formatNumber soll null/undefined als "N/A" zurückgeben
let helpers = fs.readFileSync('utils/helpers.ts', 'utf8');
helpers = helpers.replace(
  'export function formatNumber(num: number | bigint | string): string {\n  const absNum = Math.abs(Number(num));',
  "export function formatNumber(num: number | bigint | string | null | undefined): string {\n  if (num === null || num === undefined) return 'N/A';\n  const absNum = Math.abs(Number(num));"
);
// Auch am Ende von formatNumber: num.toLocaleString() absichern
helpers = helpers.replace(
  /return num\.toLocaleString\(\);/g,
  'return (num ?? 0).toLocaleString();'
);
fs.writeFileSync('utils/helpers.ts', helpers);
console.log('✓ Patched utils/helpers.ts');

// --- Patch 2: components/PoolStatsDisplay.tsx ---
// formatValue: null-Werte vor Weiterverarbeitung abfangen
let display = fs.readFileSync('components/PoolStatsDisplay.tsx', 'utf8');
display = display.replace(
  /const formatValue = \(key: string, value: any\): string => \{/,
  "const formatValue = (key: string, value: any): string => {\n    if (value === null || value === undefined) return 'N/A';"
);
fs.writeFileSync('components/PoolStatsDisplay.tsx', display);
console.log('✓ Patched components/PoolStatsDisplay.tsx');

console.log('All patches applied.');
