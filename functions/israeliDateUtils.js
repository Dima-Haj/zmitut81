// israeliDateUtils.js

const TIMEZONE = "Asia/Jerusalem";

/**
 * Get the current date and time in Israel timezone.
 * @return {Date} The current date and time in the Asia/Jerusalem timezone.
 */
const getCurrentIsraeliDate = () => {
  const now = new Date();
  const israelTimeString = now.toLocaleString("en-US", { timeZone: TIMEZONE });
  return new Date(israelTimeString);
};

/**
 * Convert a UNIX timestamp to a Date in Israel timezone.
 * @param {number} unixTimestamp - The UNIX timestamp in seconds.
 * @return {string} The formatted date in Israel timezone.
 */
const convertToIsraeliTime = (unixTimestamp) => {
  const date = new Date(unixTimestamp * 1000); // Convert seconds to milliseconds
  return date.toLocaleString("en-US", { timeZone: TIMEZONE });
};

/**
 * Format a Date object to Israeli time string.
 * @param {Date} date - The Date object to format.
 * @return {string} The formatted date string in Israel timezone.
 */
const formatIsraeliDate = (date) => {
  return new Intl.DateTimeFormat("en-US", {
    timeZone: TIMEZONE,
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
    hour: "2-digit",
    minute: "2-digit",
    second: "2-digit",
  }).format(date);
};

/**
 * Get a Date object set to 8:00 AM tomorrow in Israel timezone.
 * @return {Date} A Date object for 8:00 AM tomorrow in Israel timezone.
 */
const getTomorrowAtEightAM = () => {
  const now = getCurrentIsraeliDate();
  now.setDate(now.getDate() + 1); // Move to the next day
  now.setHours(8, 0, 0, 0); // Set to 8:00 AM
  return now;
};

module.exports = {
  getCurrentIsraeliDate,
  convertToIsraeliTime,
  formatIsraeliDate,
  getTomorrowAtEightAM,
};
