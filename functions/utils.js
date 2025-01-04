const admin = require("firebase-admin");
const axios = require("axios");

admin.initializeApp({
  credential: admin.credential.cert(require("./config/serviceAccountKey.json")),
});

const {
    getCurrentIsraeliDate,
    convertToIsraeliTime,
    formatIsraeliDate,
    getTomorrowAtEightAM,
  } = require("./israeliDateUtils");
const db = admin.firestore();

/**
 * Checks if a user is a manager.
 * @return {Promise<boolean>} Returns true if the user is a manager
 */


/**
 * Splits an order into smaller chunks if its weight exceeds the limit.
 * @param {Object} order - The order object to split.
 * @param {number} maxWeight - The maximum weight per split order.
 * @param {string} weightType - The type of weight (e.g., "טון", "ק\"ג").
 * @return {Array<Object>} An array of split orders.
 */
const splitOrder = (order, maxWeight, weightType) => {
  const splitOrders = [];
  let remainingWeight = order.weight;
  let splitCount = 1;

  while (remainingWeight > 0) {
    const currentWeight = Math.min(remainingWeight, maxWeight);
    const splitOrder = {
      ...order,
      weight: currentWeight,
      originalOrderId: order.orderId,
      splitNumber: splitCount,
      weightType,
    };
    splitOrders.push(splitOrder);
    remainingWeight -= currentWeight;
    splitCount += 1;
  }

  return splitOrders;
};

/**
 * Categorizes orders by truck type and verifies the manager's access.
 * @return {Promise<Object>} An object categorizing the orders by truck type.
 * @throws Will throw an error if the user is not a manager.
 */

const separateOrdersByTruckType = async () => {
  try {
    const clientsSnapshot = await db.collection("clients").get();
    const allOrders = {
      פלטה: {small: [], big: []},
      צובר: [],
      תפזורת: {double: [], regular: []},
    };

    for (const clientDoc of clientsSnapshot.docs) {
      const clientId = clientDoc.id;
      const ordersSnapshot = await db
          .collection("clients")
          .doc(clientId)
          .collection("orders")
          .get();

      for (const orderDoc of ordersSnapshot.docs) {
        const order = orderDoc.data();

        if (order.isPackaged) {
          if (
            (order.weightType === "ק\"ג" && order.weight <= 12000) ||
              (order.weightType === "טון" && order.weight <= 12)
          ) {
            allOrders.פלטה.small.push({
              clientId,
              orderId: orderDoc.id,
              ...order,
            });
          } else {
            const splitOrders = splitOrder(order, 12000, "ק\"ג");
            allOrders.פלטה.big.push(...splitOrders);
          }
        } else if (
          order.product === "אבן גיר" ||
            order["Sub-Product"] === "אבו גיר"
        ) {
          if (order.weight > 36) {
            const splitOrders = splitOrder(order, 36, "טון");
            allOrders.צובר.push(...splitOrders);
          } else {
            allOrders.צובר.push({
              clientId,
              orderId: orderDoc.id,
              ...order,
            });
          }
        } else {
          if (
            (order.weightType === "טון" && order.weight <= 20) ||
              (order.weightType === "ק\"ג" && order.weight <= 20000)
          ) {
            allOrders.תפזורת.regular.push({
              clientId,
              orderId: orderDoc.id,
              ...order,
            });
          } else if (
            (order.weightType === "טון" && order.weight <= 40) ||
              (order.weightType === "ק\"ג" && order.weight <= 40000)
          ) {
            allOrders.תפזורת.double.push({
              clientId,
              orderId: orderDoc.id,
              ...order,
            });
          }
        }
      }
    }

    // console.log("Orders categorized by truck type:");
    // console.log(JSON.stringify(allOrders, null, 2));
    const categorizedOrdersRef = db.collection("categorizedOrders");

    // Save פלטה
    await categorizedOrdersRef.doc("פלטה").set(allOrders.פלטה);

    // Save צובר
    await categorizedOrdersRef.doc("צובר").set({orders: allOrders.צובר});

    // Save תפזורת
    await categorizedOrdersRef.doc("תפזורת").set(allOrders.תפזורת);

    console.log("Categorized orders saved to Firestore.");
    return allOrders;
  } catch (error) {
    console.error("Error categorizing orders:", error);
    throw error;
  }
};
separateOrdersByTruckType();

const GOOGLE_API_KEY = "AIzaSyBXHnIAKqan9xNW5XEgaPe1JBVgFAexIR8";

// Company Location (צמיתות 81 בע"ם)
const COMPANY_LOCATION = {latitude: 32.849758840523386,
  longitude: 35.17350796263602};

// Function to fetch travel times using Google Maps API
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
  // Assign deliveries with latitude and longitude
  const assignDeliveries = async () => {
    try {
      const MAX_WORK_HOURS = 8; // 8 hours in seconds
      const PREPARATION_TIME = 30; // 30 minutes in seconds
      const CLIENT_WAITING_TIME = 30; // 30 minutes in seconds
      const postponedDeliveries = []; // Store postponed deliveries for the next day
  
      // Fetch employees and orders
      const employeesSnapshot = await db.collection("Employees").get();
      const employees = employeesSnapshot.docs.map((doc) => ({
        employeeDocId: doc.id,
        ...doc.data(),
        deliveries: [],
        totalDurationHours: 0, // Start tracking total work hours from 8:00 AM
        totalDurationMinutes: 0,
      }));
  
      const clientsSnapshot = await db.collection("clients").get();
      const allOrders = [];
  
      for (const clientDoc of clientsSnapshot.docs) {
        const clientId = clientDoc.id;
        const clientData = clientDoc.data();
  
        const ordersSnapshot = await db
          .collection("clients")
          .doc(clientId)
          .collection("orders")
          .get();
        for (const orderDoc of ordersSnapshot.docs) {
          allOrders.push({
            clientId,
            clientAddress: clientData.address,
            clientPhone: clientData.phone,
            clientName: clientData.name,
            ...orderDoc.data(),
          });
        }
      }
  
      // Group orders by truck type
      const ordersByTruckType = {
        פלטה: allOrders.filter((order) => order.isPackaged),
        צובר: allOrders.filter((order) => !order.isPackaged && order.product === "אבן גיר"),
        תפזורת: allOrders.filter((order) => !order.isPackaged && order.product !== "אבן גיר"),
      };
  
      for (const truckType in ordersByTruckType) {
        if (Object.prototype.hasOwnProperty.call(ordersByTruckType, truckType)) {
          const orders = ordersByTruckType[truckType];
          const truckEmployees = employees.filter((e) => e.truckType === truckType);
  
          if (orders.length === 0 || truckEmployees.length === 0) continue;
  
          // Assign orders to minimize drivers and balance workload
          const assignments = balanceOrdersAmongDrivers(orders, truckEmployees);
  
          for (const assignment of assignments) {
            const driver = truckEmployees.find((e) => e.employeeDocId === assignment.driverId);
            if (!driver) continue;
            const START_TIME = getTomorrowAtEightAM();
            let currentTime = new Date(START_TIME); 
            currentTime/=1000;
            let currenthours=0;
            let currentminutes=0;
            for (const order of assignment.orders) {
              const optimizedRoute = await optimizeRouteForDriver(
                order,
                COMPANY_LOCATION,
                PREPARATION_TIME,
                CLIENT_WAITING_TIME,
                currentTime,
              );
              currenthours+=optimizedRoute[0].totalDeliveryTime.hours;
              currentminutes+=optimizedRoute[0].totalDeliveryTime.minutes;
              if (currentminutes>=60) {
                currenthours++;
                currentminutes-=60;
              }
              if (currenthours > 8 || currenthours==8 && currentminutes!=0) {
                // Exceeds daily limit; postpone the delivery
                postponedDeliveries.push(order);
              } else {
                // Add to driver's deliveries
                driver.deliveries.push(...optimizedRoute);
                currentTime+= optimizedRoute[0].totalDeliveryTime.hours*3600 + optimizedRoute[0].totalDeliveryTime.minutes*60;
                console.log("new current time:", +currentTime);
              }
            }
          }
        }
      }
  
      // Save assignments to Firestore
      for (const driver of employees) {
        if (driver.deliveries.length > 0) {
          const date = new Date().toISOString().split("T")[0];
          const dailyDeliveriesRef = db
            .collection("Employees")
            .doc(driver.employeeDocId)
            .collection("dailyDeliveries");
  
          const batch = db.batch();
          const existingDeliveriesSnapshot = await dailyDeliveriesRef.get();
  
          existingDeliveriesSnapshot.forEach((doc) => batch.delete(doc.ref));
          if (!existingDeliveriesSnapshot.empty) await batch.commit();
  
          for (const delivery of driver.deliveries) {
            await dailyDeliveriesRef.doc(`${date}-${delivery.orderId}`).set({
              ...delivery,
              date,
            });
          }
        }
      }
  
      // Save postponed deliveries
      if (postponedDeliveries.length > 0) {
        const date = new Date();
        date.setDate(date.getDate() + 1); // Postpone to the next day
        const nextDay = date.toISOString().split("T")[0];
        const postponedRef = db.collection("PostponedDeliveries");
  
        for (const postponed of postponedDeliveries) {
          await postponedRef.doc(`${nextDay}-${postponed.orderId}`).set({
            ...postponed,
            date: nextDay,
          });
        }
      }
  
      printEmployeeWorkSummary(employees);
  
      console.log("Delivery assignments completed.");
    } catch (error) {
      console.error("Error assigning deliveries:", error);
    }
  };
  
  
  // Helper function to balance orders among drivers
  const balanceOrdersAmongDrivers = (orders, drivers) => {
    const assignments = drivers.map((d) => ({driverId: d.employeeDocId, orders: []}));
    orders.sort((a, b) => b.weight - a.weight); // Assign heavier orders first
  
    for (const order of orders) {
      const driver = assignments.reduce((a, b) => (a.orders.length <= b.orders.length ? a : b));
      driver.orders.push(order);
    }
  
    return assignments;
  };
  
  // Helper function to optimize a route
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
    
    // Debug log
    
    const route = [];
    const trail1 = new Date(startTime * 1000);
    console.log("before: "+trail1.getHours()+" "+trail1.getMinutes());
    // Update start time to account for preparation
    startTime += (30 * 60);
    const trail2 = new Date(startTime * 1000);
    console.log("after: "+trail2.getHours()+" "+trail2.getMinutes());
    // Calculate travel time to the destination
    const travelToDestination = await calculateTravelTime(
      companyLocation,
      { latitude: clientLat, longitude: clientLng },
      startTime // Pass the current time for departure
    );
  
    if (!travelToDestination) {
      console.warn(`Failed to calculate travel time for order ${order.orderId}. Skipping...`);
      return null; // Skip the order if travel time cannot be calculated
    }
  
    // Update start time to reflect travel time to the destination
    startTime += travelToDestination.duration;
    
  
    // Simulate delivery waiting time
    startTime += (30 * 60);
  
    // Calculate travel time back to the company
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
  
    const departureTime = new Date((startTime - (travelBackToCompany.duration + travelToDestination.duration + (waitingTime * 60))) * 1000);
    console.log("begin: "+departureTime.getHours()+" "+departureTime.getMinutes());
    const arrivalTime = new Date((startTime - (travelBackToCompany.duration + (waitingTime * 60))) * 1000);
    const returnTime = new Date((startTime - travelBackToCompany.duration) * 1000);
    route.push({
      ...order,
      departureTime: departureTime.toLocaleString("en-US", { timeZone: "Asia/Jerusalem" }), // Time when the driver departs for delivery
      arrivalTime: arrivalTime.toLocaleString('en-US', { timeZone: 'Asia/Jerusalem' }), // Time when the driver arrives at the client
      returnTime: returnTime.toLocaleString('en-US', { timeZone: 'Asia/Jerusalem' }), // Time when the driver returns to the company
      travelToDestination: secondsToTime(travelToDestination.duration), // Travel time to the destination
      travelBackToCompany: secondsToTime(travelBackToCompany.duration), // Travel time back to the company
      totalDeliveryTime: secondsToTime(
        travelToDestination.duration + travelBackToCompany.duration + waitingTime * 60 + preparationTime * 60
      ), // Total time for this delivery
    });
  
    return route;
  };
  
const printEmployeeWorkSummary = (employees) => {
    console.log("Daily Work Summary for Employees:");
  
    employees.forEach((employee) => {
      const workHours = Math.floor(employee.totalDuration / 3600); // Convert seconds to hours
      const workMinutes = Math.floor((employee.totalDuration % 3600) / 60); // Remaining minutes
      console.log(`Employee: ${employee.name || employee.employeeDocId}`);
      console.log(`Truck Type: ${employee.truckType}`);
      console.log(`Total Work Time: ${workHours} hours and ${workMinutes} minutes`);
      console.log(`Number of Deliveries: ${employee.deliveries.length}`);
  
      employee.deliveries.forEach((delivery, index) => {
        console.log(`  Delivery ${index + 1}:`);
        console.log(`    Order ID: ${delivery.orderId}`);
        console.log(`    Client Name: ${delivery.clientName}`);
        console.log(`    Client Address: ${delivery.clientAddress}`);
        console.log(`    Travel Time: ${Math.floor(delivery.travelTime / 60)} minutes`);
        console.log(`    Preparation Time: 
          ${Math.floor(delivery.preparationTime / 60)} minutes`);
      console.log(`    Waiting Time: 
        ${Math.floor(delivery.waitingTime / 60)} minutes`);
      console.log(`    Total Time: ${Math.floor(delivery.totalTime / 60)} minutes`);
    });
    console.log("--------------------------------------------------");
  });
  console.log("Summary generated successfully.");
};
assignDeliveries().then().catch(console.error);
module.exports = {
  assignDeliveries,
  separateOrdersByTruckType,
};
