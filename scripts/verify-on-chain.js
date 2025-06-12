#!/usr/bin/env node
// PATCHED v0.1.45 scripts/verify-on-chain.js — Verify commit hash on chain

import { ethers } from 'ethers';
import { execSync } from 'child_process';

const localShaHex = execSync('git rev-parse HEAD', {
  cwd: process.cwd(),
}).toString().trim();
if (!/^[0-9a-f]{40}$/.test(localShaHex)) {
  console.error('Invalid commit SHA');
  process.exit(1);
}
const localBytes32 = '0x' + localShaHex.padStart(64, '0');

const {
  DEVONBOARDER_ETHEREUM_RPC_URL,
  DEVONBOARDER_ANCHOR_CONTRACT_ADDRESS,
  DEVONBOARDER_REPO_ANCHOR_KEY,
} = process.env;
if (
  !DEVONBOARDER_ETHEREUM_RPC_URL ||
  !DEVONBOARDER_ANCHOR_CONTRACT_ADDRESS ||
  !DEVONBOARDER_REPO_ANCHOR_KEY
) {
  console.error('Missing environment variables');
  process.exit(1);
}

const provider = new ethers.JsonRpcProvider(DEVONBOARDER_ETHEREUM_RPC_URL);
const codeAnchor = new ethers.Contract(
  DEVONBOARDER_ANCHOR_CONTRACT_ADDRESS,
  ['function getHash(string memory) external view returns (bytes32)'],
  provider
);

const onChainHash = await codeAnchor.getHash(DEVONBOARDER_REPO_ANCHOR_KEY);
if (onChainHash.toLowerCase() === localBytes32.toLowerCase()) {
  console.log('[OK] Local code matches on-chain reference.');
  process.exit(0);
}
console.error(`[MISMATCH] Local: ${localBytes32}, On-chain: ${onChainHash}`);
process.exit(1);
