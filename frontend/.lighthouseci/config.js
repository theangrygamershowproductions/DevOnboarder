/* eslint-disable no-undef */

// LHCI config must use CommonJS
module.exports = {
    ci: {
        collect: {
            numberOfRuns: 3,
            url: ['http://localhost:43585/'], // Test the root route
            chromePath: '/usr/bin/google-chrome',
            chromeFlags: [
                '--headless=new',
                '--no-sandbox',
                '--disable-gpu',
                '--disable-dev-shm-usage',
                '--disable-background-networking',
                '--disable-sync',
                '--metrics-recording-only',
                '--no-first-run',
                '--no-default-browser-check',
                '--mute-audio',
                '--disable-extensions',
            ],
        },
        upload: { target: 'temporary-public-storage' },
    },
};
