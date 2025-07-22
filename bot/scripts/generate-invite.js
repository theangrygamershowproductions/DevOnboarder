const { generateInviteLink } = require('../utils/generateInviteLink');
require('dotenv').config();

console.log('🔗 Discord Bot Invite Link Generator');
console.log('====================================');
console.log('');

// Get client ID from environment
const clientId = process.env.DISCORD_CLIENT_ID;

if (!clientId) {
    console.error('❌ DISCORD_CLIENT_ID not found in environment variables');
    console.log('');
    console.log('Please set DISCORD_CLIENT_ID in your .env file');
    console.log('You can find this in your Discord Developer Portal:');
    console.log('   1. Go to https://discord.com/developers/applications');
    console.log('   2. Select your application');
    console.log('   3. Copy the "Application ID" from General Information');
    process.exit(1);
}

// Generate invite link
const invite = generateInviteLink(clientId);

console.log('✅ Bot Invite Link Generated!');
console.log('');
console.log('🔗 Invite URL:');
console.log(invite.url);
console.log('');
console.log('📋 Required Permissions:');
invite.permissionsList.forEach((permission) => {
    console.log(`   ✓ ${permission}`);
});
console.log('');
console.log('🎯 Target Servers:');
console.log('   • TAGS: DevOnboarder (Development) - ID: 1386935663139749998');
console.log('   • TAGS: C2C (Production) - ID: 1065367728992571444');
console.log('');
console.log('📋 Next Steps:');
console.log('   1. Click the invite link above');
console.log('   2. Select the server to add the bot to');
console.log('   3. Ensure all permissions are granted');
console.log('   4. Test the bot connection');
console.log('');
console.log('⚠️  Important:');
console.log(
    '   - You must have "Manage Server" permission on the target server',
);
console.log('   - Grant all requested permissions for full functionality');
console.log('   - Test in DevOnboarder server first before production');
