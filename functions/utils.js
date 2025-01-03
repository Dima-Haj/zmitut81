const admin = require("firebase-admin");
const axios = require("axios");

admin.initializeApp({
  credential: admin.credential.cert(require("./config/serviceAccountKey.json")),
});


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

    console.log("Orders categorized by truck type:");
    console.log(JSON.stringify(allOrders, null, 2));
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
const calculateTravelTime = async (origin, destinations) => {
  try {
    const destinationString = destinations
        .map((d) => `${d.latitude},${d.longitude}`)
        .join("|");
    const url = `https://maps.googleapis.com/maps/api/distancematrix/json?units=metric&origins=${origin.latitude},${origin.longitude}&destinations=${destinationString}&mode=driving&departure_time=now&traffic_model=best_guess&key=${GOOGLE_API_KEY}`;
    const response = await axios.get(url);

    console.log("API Response:", JSON.stringify(response.data, null, 2));

    const results = response.data && response.data.rows &&
    response.data.rows[0] ?
    response.data.rows[0].elements :
    [];
    return results.map((result, index) => {
      if (!result || !result.distance || 
        (!result.duration && !result.duration_in_traffic)) {
        console.warn(`Missing data for destination: ${destinations[index]}. Skipping...`);
        return null; // Skip invalid results
      }
      return {
        destination: destinations[index],
        distance: result.distance.value, // Distance in meters
        duration: result.duration_in_traffic? result.duration_in_traffic.value : (result.duration && result.duration.value),
      };
    }).filter((result) => result !== null);
    
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
    //  const MAX_WORK_HOURS = 8 * 60 * 60; // 8 hours in seconds
      const PREPARATION_TIME = 30 * 60; // 30 minutes in seconds
      const CLIENT_WAITING_TIME = 30 * 60; // 30 minutes in seconds
  
      // Fetch employees and orders
      const employeesSnapshot = await db.collection("Employees").get();
      const employees = employeesSnapshot.docs.map((doc) => ({
        employeeDocId: doc.id,
        ...doc.data(),
        deliveries: [],
        totalDuration: 0,
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
      
            const optimizedRoute = await optimizeRouteForDriver(
              assignment.orders,
              COMPANY_LOCATION,
              PREPARATION_TIME,
              CLIENT_WAITING_TIME,
            );
      
            driver.deliveries.push(...optimizedRoute);
            driver.totalDuration += optimizedRoute.reduce((sum, d) => sum + d.totalTime, 0);
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
  const optimizeRouteForDriver = async (orders, companyLocation, preparationTime, waitingTime) => {
    // Ensure all orders have location data
    for (const order of orders) {
      if (!order.clientLat || !order.clientLng) {
        try {
          console.warn(`Order ${order.orderId} is missing location data. Fetching...`);
          const location = await getLatLngFromAddress(order.clientAddress);
          order.clientLat = location.lat;
          order.clientLng = location.lng;
        } catch (error) {
          console.error(`Failed to fetch location for order ${order.orderId}:`, error);
          continue; // Skip this order if location fetch fails
        }
      }
    }
  
    // Filter orders with valid locations
    const validOrders = orders.filter((order) => order.clientLat && order.clientLng);
    if (!validOrders.length) {
      console.error("No valid orders with location data found.");
      return [];
    }
  
    const destinations = validOrders.map((order) => ({
      latitude: order.clientLat,
      longitude: order.clientLng,
    }));
  
    // Fetch travel times
    const travelTimes = await calculateTravelTime(companyLocation, destinations);
  
    // Construct route details
    const route = validOrders.map((order, index) => {
      const travelTime = travelTimes[index]?.duration || 0; // Default to 0 if travel time is missing
      return {
        ...order,
        travelTime,
        preparationTime,
        waitingTime,
        totalTime: travelTime + preparationTime + waitingTime,
      };
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
