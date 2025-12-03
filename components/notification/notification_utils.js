/**
 * @param { string } summary
 * @returns { string }
 */
function findSuitableMaterialSymbol(summary) {
  const defaultType = "notifications";
  if (!summary || summary.length === 0) return defaultType;

  const keywordsToTypes = {
    reboot: "restart_alt",
    record: "screen_record",
    battery: "battery_alert",
    power: "power",
    screenshot: "screenshot_monitor",
    welcome: "waving_hand",
    time: "schedule",
    installed: "download",
    "configuration reloaded": "settings",
    config: "settings",
    update: "update",
    control: "settings",
    install: "download",
  };

  const lowerSummary = summary.toLowerCase();

  for (const keyword in keywordsToTypes) {
    if (lowerSummary.includes(keyword)) {
      return keywordsToTypes[keyword];
    }
  }

  return defaultType;
}

/**
 * @param { number | string | Date } timestamp
 * @returns { string }
 */
function getFriendlyNotifTimeString(timestamp) {
  if (!timestamp) return "";

  const messageTime = new Date(timestamp);
  const now = new Date();
  const diffMs = now.getTime() - messageTime.getTime();

  // Less than 1 minute
  if (diffMs < 60000) return "Now";

  // Same day - show relative time
  if (messageTime.toDateString() === now.toDateString()) {
    const diffMinutes = Math.floor(diffMs / 60000);
    const diffHours = Math.floor(diffMs / 3600000);

    if (diffHours > 0) {
      return diffHours + "h";
    } else {
      return diffMinutes + "m";
    }
  }

  // Yesterday
  if (
    messageTime.toDateString() ===
    new Date(now.getTime() - 86400000).toDateString()
  )
    return "Yesterday";

  // Older dates
  return Qt.formatDateTime(messageTime, "MMM dd");
}
