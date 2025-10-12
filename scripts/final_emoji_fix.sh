#!/bin/bash
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Quick emoji fix for Phase 3 framework scripts

cd /home/potato/DevOnboarder || exit

echo "Fixing remaining emojis in Phase 3 framework..."

# Target directory (configurable)
TARGET_DIR="${TARGET_DIR:-frameworks/monitoring_automation/}"

# More comprehensive emoji fixes
find "$TARGET_DIR" -name "*.sh" -exec sed -i '
s/🏥/HEALTH:/g
s/🚨/ALERT:/g
s/⏰/TIME:/g
s/💚/HEALTHY:/g
s/🧪/TEST:/g
s/📈/TREND:/g
s/📉/DOWN:/g
s/TOOL:/TOOL:/g
s/🔨/BUILD:/g
s/⭐/STAR:/g
s/🔀/MERGE:/g
s/SYNC:/RELOAD:/g
s/REPORT:/REPORT:/g
s/CHECK:/LIST:/g
s/TARGET:/GOAL:/g
s/✨/NEW:/g
s/SECURE:/SECURE:/g
s/🔓/OPEN:/g
s/💾/SAVE:/g
s/📤/UPLOAD:/g
s/📥/DOWNLOAD:/g
s/🖥️/SYSTEM:/g
s/📱/MOBILE:/g
s/⚙️/CONFIG:/g
s/WEB:/NETWORK:/g
s/🗂️/FILES:/g
s/📁/FOLDER:/g
s/📄/DOC:/g
s/🎨/STYLE:/g
s/🔍/SEARCH:/g
s/SUCCESS:/OK:/g
s/ERROR:/FAIL:/g
s/WARNING:/WARN:/g
s/DEPLOY:/START:/g
s/🛑/STOP:/g
s/⏸️/PAUSE:/g
s/⏯️/PLAY:/g
s/📺/VIEW:/g
s/🔊/SOUND:/g
s/🔇/MUTE:/g
s/🎵/MUSIC:/g
s/🎶/NOTES:/g
s/🔔/NOTIFY:/g
s/🔕/SILENT:/g
s/💡/IDEA:/g
s/🔥/HOT:/g
s/❄️/COLD:/g
s/⚡/FAST:/g
s/🐌/SLOW:/g
s/🏃/RUN:/g
s/🚶/WALK:/g
s/TOOL:/REPAIR:/g
s/🔨/HAMMER:/g
s/🪓/AXE:/g
s/⚔️/SWORD:/g
s/🏹/ARROW:/g
s/🛡️/SHIELD:/g
s/🗡️/BLADE:/g
s/🔪/KNIFE:/g
s/🔫/GUN:/g
s/💣/BOMB:/g
s/🧨/TNT:/g
' {} \;

echo "Unicode cleanup complete"

# Count remaining violations
REMAINING=$(grep -r '[^[:print:]]' frameworks/monitoring_automation/ 2>/dev/null | wc -l)
echo "Remaining non-ASCII characters: $REMAINING"

if [ "$REMAINING" -eq 0 ]; then
    success "Phase 3 framework is now terminal output compliant"
else
    echo "Some characters may remain - checking..."
    grep -r '[^[:print:]]' frameworks/monitoring_automation/ | head -3
fi
