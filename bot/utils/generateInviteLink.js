const { PermissionsBitField } = require('discord.js');

/**
 * Generate Discord bot invite link with proper permissions
 */
function generateInviteLink(clientId, permissions = null) {
    // Default permissions for DevOnboarder bot (Discord.js v14 compatible)
    const defaultPermissions = [
        PermissionsBitField.Flags.ViewChannel,
        PermissionsBitField.Flags.SendMessages,
        PermissionsBitField.Flags.SendMessagesInThreads,
        PermissionsBitField.Flags.EmbedLinks,
        PermissionsBitField.Flags.AttachFiles,
        PermissionsBitField.Flags.ReadMessageHistory,
        PermissionsBitField.Flags.UseExternalEmojis,
        PermissionsBitField.Flags.AddReactions,
        PermissionsBitField.Flags.UseApplicationCommands,
        PermissionsBitField.Flags.ManageMessages, // For moderation features
        PermissionsBitField.Flags.ManageRoles, // For role management
        PermissionsBitField.Flags.Connect, // For voice channels if needed
        PermissionsBitField.Flags.Speak, // For voice channels if needed
    ];

    const permissionValue =
        permissions || new PermissionsBitField(defaultPermissions).bitfield;

    const inviteUrl = `https://discord.com/api/oauth2/authorize?client_id=${clientId}&permissions=${permissionValue}&scope=bot%20applications.commands`;

    return {
        url: inviteUrl,
        permissions: permissionValue,
        permissionsList: defaultPermissions
            .map((flag) => {
                return Object.keys(PermissionsBitField.Flags).find(
                    (key) => PermissionsBitField.Flags[key] === flag,
                );
            })
            .filter(Boolean), // Remove any undefined values
    };
}

module.exports = { generateInviteLink };
