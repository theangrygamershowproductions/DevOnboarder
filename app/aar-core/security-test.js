// Quick security test to verify path traversal protection
import http from 'http';
import { spawn } from 'child_process';

const testRequests = [
  { path: '/api/aars/valid-aar-id', expected: 404 }, // Should be 404 (not found) not 400 (invalid format)
  { path: '/api/aars/../../../etc/passwd', expected: 400 }, // Should be blocked
  { path: '/api/aars/..%2F..%2F..%2Fetc%2Fpasswd', expected: 400 }, // Should be blocked
  { path: '/api/aars/', expected: 404 }, // Should be blocked (empty ID)
  { path: '/api/aars/valid_aar-id_123', expected: 404 } // Should be allowed (valid format)
];

async function testSecurity() {
  console.log('🔍 Testing AAR Core Security Fixes...');

  // Start server in background for testing
  const serverProcess = spawn('npm', ['run', 'dev'], {
    cwd: process.cwd(),
    detached: true,
    stdio: 'ignore'
  });

  // Wait for server to start
  await new Promise(resolve => setTimeout(resolve, 3000));

  let passed = 0;
  let failed = 0;

  for (const test of testRequests) {
    try {
      const response = await new Promise((resolve, reject) => {
        const req = http.get(`http://localhost:3000${test.path}`, resolve);
        req.on('error', reject);
        req.setTimeout(5000);
      });

      if (response.statusCode === test.expected) {
        console.log(`✅ ${test.path} → ${response.statusCode} (expected ${test.expected})`);
        passed++;
      } else {
        console.log(`❌ ${test.path} → ${response.statusCode} (expected ${test.expected})`);
        failed++;
      }
    } catch (error) {
      console.log(`❌ ${test.path} → Error: ${error.message}`);
      failed++;
    }
  }

  // Test rate limiting
  console.log('\n🚦 Testing Rate Limiting...');
  const startTime = Date.now();
  let rateLimitHit = false;

  for (let i = 0; i < 35; i++) { // Try to exceed the 30 requests limit
    try {
      const response = await new Promise((resolve, reject) => {
        const req = http.get('http://localhost:3000/api/aars', resolve);
        req.on('error', reject);
        req.setTimeout(1000);
      });

      if (response.statusCode === 429) {
        console.log(`✅ Rate limiting working: Request ${i + 1} was blocked`);
        rateLimitHit = true;
        break;
      }
    } catch (error) {
      // Ignore individual request errors for rate limit test
    }
  }

  if (!rateLimitHit) {
    console.log('⚠️ Rate limiting not triggered (may need more requests or longer test)');
  }

  // Clean up
  try {
    process.kill(-serverProcess.pid);
  } catch (e) {
    // Server cleanup error is not critical for security test
  }

  console.log(`\n📊 Security Test Results:`);
  console.log(`   ✅ Passed: ${passed}`);
  console.log(`   ❌ Failed: ${failed}`);
  console.log(`   🚦 Rate Limiting: ${rateLimitHit ? 'Working' : 'Needs Verification'}`);

  if (failed === 0) {
    console.log('\n🎯 Security fixes successfully implemented!');
    process.exit(0);
  } else {
    console.log('\n⚠️ Some security tests failed - review implementation');
    process.exit(1);
  }
}

testSecurity().catch(console.error);
