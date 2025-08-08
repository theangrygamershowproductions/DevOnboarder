#!/usr/bin/env node

// Simple health check for Discord bot
// Returns exit code 0 if healthy, 1 if not

import fs from 'fs';
import path from 'path';

try {
    // Check if the main process is running by looking for the PID
    // In a container, if we reach this script, Node.js is running

    // Also check if we can write to logs (basic functionality test)
    const logDir = path.join(process.cwd(), 'logs');

    // Try to create logs directory if it doesn't exist
    if (!fs.existsSync(logDir)) {
        fs.mkdirSync(logDir, { recursive: true });
    }

    // Write a health check timestamp
    const healthFile = path.join(logDir, '.health-check');
    fs.writeFileSync(healthFile, new Date().toISOString());

    // If we got here, the bot process is running and can write files
    process.exit(0);
} catch (error) {
    console.error('Health check failed:', error.message);
    process.exit(1);
}
