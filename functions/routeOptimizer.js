const { DateTime } = require('luxon');
const { calculateTravelTime } = require('./googleMapsApi');
const { getLatLngFromAddress } = require('./geocodeApi');

/**
 * Optimizes the route for a driver based on a single order.
 * @param {Object} order - The order object to optimize the route for.
 * @param {Object} companyLocation - The company's latitude and longitude.
 * @param {number} preparationTime - Preparation time in minutes.
 * @param {number} waitingTime - Waiting time at the client in minutes.
 * @param {number} startTime - Start time in Unix seconds.
 * @return {Promise<Array>} The optimized route containing details for this order.
 */

const optimizeRouteForDriver = async (order, companyLocation, preparationTime, waitingTime, startTime) => {
    if (!order.clientLat || !order.clientLng) {
      try {
        console.warn(`Order ${order.orderId} is missing location data. Fetching...`);
        const location = await getLatLngFromAddress(order.clientAddress);
        order.clientLat = location.lat;
        order.clientLng = location.lng;
      } catch (error) {
        console.error(`Failed to fetch location for order ${order.orderId}:`, error);
        return null; // Skip the order if location fetching fails
      }
    }
    
    // Ensure clientLat and clientLng are valid numbers
    const clientLat = parseFloat(order.clientLat);
    const clientLng = parseFloat(order.clientLng);
    
    if (isNaN(clientLat) || isNaN(clientLng)) {
      console.error(`Invalid latitude or longitude for order ${order.orderId}:`, { clientLat, clientLng });
      return; // Skip this order
    }
    const route = [];
    startTime += (30 * 60);
    const travelToDestination = await calculateTravelTime(
      companyLocation,
      { latitude: clientLat, longitude: clientLng },
      startTime // Pass the current time for departure
    );
  
    if (!travelToDestination) {
      console.warn(`Failed to calculate travel time for order ${order.orderId}. Skipping...`);
      return null; // Skip the order if travel time cannot be calculated
    }

    startTime += travelToDestination.duration;
    startTime += (30 * 60);
    const travelBackToCompany = await calculateTravelTime(
      { latitude: order.clientLat, longitude: order.clientLng },
      companyLocation,
      startTime // Pass the updated current time
    );
  
    if (!travelBackToCompany) {
      console.warn(`Failed to calculate return travel time for order ${order.orderId}. Skipping...`);
      return null; // Skip the order if return travel time cannot be calculated
    }
  
    // Update start time to reflect travel time back to the company
    startTime += travelBackToCompany.duration;
  
    // Convert seconds to hours and minutes for readability
    const secondsToTime = (seconds) => {
      const hours = Math.floor(seconds / 3600);
      const minutes = Math.floor((seconds % 3600) / 60);
      return { hours, minutes };
    };
  
    const departureTime = DateTime.fromSeconds(
        startTime - (travelBackToCompany.duration + travelToDestination.duration + (waitingTime * 60)),
        { zone: 'Asia/Jerusalem' }
      );
            
      const arrivalTime = DateTime.fromSeconds(
        startTime - (travelBackToCompany.duration + (waitingTime * 60)),
        { zone: 'Asia/Jerusalem' }
      );
            
      const returnTime = DateTime.fromSeconds(
        startTime - travelBackToCompany.duration,
        { zone: 'Asia/Jerusalem' }
      );
      
    route.push({
      ...order,
      departureTime: departureTime.toFormat('yyyy-MM-dd HH:mm'), // Format directly from DateTime
      arrivalTime: arrivalTime.toFormat('yyyy-MM-dd HH:mm'), // Format directly from DateTime
      returnTime: returnTime.toFormat('yyyy-MM-dd HH:mm'), // Format directly from DateTime
      travelToDestination: secondsToTime(travelToDestination.duration), // Travel time to the destination
      travelBackToCompany: secondsToTime(travelBackToCompany.duration), // Travel time back to the company
      totalDeliveryTime: secondsToTime(
        travelToDestination.duration + travelBackToCompany.duration + waitingTime * 60 + preparationTime * 60
      ), // Total time for this delivery
    });
  
    return route;
  };

  
  // Export the function for use in other files
module.exports = {
    optimizeRouteForDriver,
  };

