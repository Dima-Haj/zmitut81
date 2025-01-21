const axios = require('axios');

// Replace with your Google API Key
const GOOGLE_API_KEY = "AIzaSyAGJkXj13xt1A665k3XO5GspS6i6tbieuA";

/**
 * Calculate travel time using Google Distance Matrix API.
 * @param {Object} origin - The origin location { latitude, longitude }.
 * @param {Object} destination - The destination location { latitude, longitude }.
 * @param {number} departureTime - The departure time as a Unix timestamp.
 * @return {Object|null} - Returns travel details or null if missing data.
 */

const calculateTravelTime = async (origin, destination, departureTime) => {
    try {
      const destinationString = `${destination.latitude},${destination.longitude}`;
      const url = `https://maps.googleapis.com/maps/api/distancematrix/json?units=metric&origins=${origin.latitude},${origin.longitude}&destinations=${destinationString}&mode=driving&departure_time=${departureTime}&traffic_model=best_guess&key=${GOOGLE_API_KEY}`;
      const response = await axios.get(url);   
      const result = response.data && response.data.rows &&
        response.data.rows[0] && response.data.rows[0].elements &&
        response.data.rows[0].elements[0];
  
      if (!result || !result.distance || (!result.duration && !result.duration_in_traffic)) {
        console.warn(`Missing data for destination: ${destinationString}.`);
        return null; // Skip invalid results
      }
  
      return {
        destination,
        distance: result.distance.value, // Distance in meters
        duration: result.duration_in_traffic ? result.duration_in_traffic.value : result.duration.value, // Duration in seconds
      };
    } catch (error) {
      console.error("Error fetching travel time:", error);
      throw error;
    }
  };

  module.exports = { calculateTravelTime };
