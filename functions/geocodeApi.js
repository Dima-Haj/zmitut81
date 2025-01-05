const axios = require('axios');

// Replace with your Google API Key
const GOOGLE_API_KEY = "AIzaSyBXHnIAKqan9xNW5XEgaPe1JBVgFAexIR8";

/**
 * Fetch latitude and longitude for a given address using Google Geocoding API.
 * @param {string} address - The address to fetch coordinates for.
 * @return {Object} - Returns an object with latitude and longitude.
 * @throws Will throw an error if the address cannot be resolved.
 */

const getLatLngFromAddress = async (address) => {
    try {
      const url = `https://maps.googleapis.com/maps/api/geocode/json?address=${encodeURIComponent(address)}&key=${GOOGLE_API_KEY}`;
      const response = await axios.get(url);
      const location = 
      response.data.results &&
      response.data.results[0] &&
      response.data.results[0].geometry &&
      response.data.results[0].geometry.location;
      
      if (!location) {
        throw new Error(`Failed to fetch coordinates for address: ${address}`);
      }
  
      return location; // Returns { lat, lng }
    } catch (error) {
      console.error(`Error fetching lat/lng for address: ${address}`, error);
      throw error;
    }
  };

  module.exports = { getLatLngFromAddress };

