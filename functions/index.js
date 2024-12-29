const admin = require("firebase-admin");
const axios = require("axios");


admin.initializeApp({
  credential: admin.credential.cert(require("./config/serviceAccountKey.json")),
  databaseURL: "https://zmitut81-1af26.firebaseio.com",
  projectId: "zmitut81-1af26", // Replace with your Firebase project ID
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
const COMPANY_LOCATION = {latitude: 32.849758840523386, longitude: 35.17350796263602};

// Function to fetch travel times using Google Maps API
const calculateTravelTime = async (origin, destinations) => {
  try {
    const destinationString = destinations.map((d) =>
      `${d.latitude},${d.longitude}`).join("|");
    const url = `https://maps.googleapis.com/maps/api/distancematrix/json?units=metric&origins=${origin.latitude},${origin.longitude}&destinations=${destinationString}&mode=driving&departure_time=now&traffic_model=best_guess&key=${GOOGLE_API_KEY}`;
    const response = await axios.get(url);
  
    console.log("API Response:", JSON.stringify(response.data, null, 2)); // Log the response

    const results = response.data.rows[0]?.elements;

    return results.map((result, index) => ({
      destination: destinations[index],
      distance: result.distance.value, // Distance in meters
      duration: result.duration_in_traffic ? result.duration_in_traffic.value :
       result.duration.value, // Duration in seconds
    }));
  } catch (error) {
    console.error("Error fetching travel time:", error);
    throw error;
  }
};

const getLatLngFromAddress = async (address) => {
    try {
      const url = `https://maps.googleapis.com/maps/api/geocode/json?address=${encodeURIComponent(address)}&key=${GOOGLE_API_KEY}`;
      const response = await axios.get(url);
      const location = response.data.results[0]?.geometry?.location;
  
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
      // Fetch employees and their truck types
      const employeesSnapshot = await db.collection("Employees").get();
      const employees = employeesSnapshot.docs.map((doc) => ({
        employeeDocId: doc.id,
        ...doc.data(),
        deliveries: [],
        totalDuration: 0,
      }));
  
      // Fetch clients and their orders
      const clientsSnapshot = await db.collection("clients").get();
      const allOrders = [];
  
      for (const clientDoc of clientsSnapshot.docs) {
        const clientId = clientDoc.id;
        const clientData = clientDoc.data();
  
        const ordersSnapshot = await db.collection("clients")
            .doc(clientId).collection("orders").get();
        for (const orderDoc of ordersSnapshot.docs) {
          const order = {
            clientId,
            clientAddress: clientData.address, // Assume each client has an address field
            ...orderDoc.data(),
          };
          allOrders.push(order);
        }
      }
  
      // Group orders by truck type
      const ordersByTruckType = {
        פלטה: allOrders.filter((order) => order.isPackaged),
        צובר: allOrders.filter((order) =>
          !order.isPackaged && order.product === "אבן גיר"),
        תפזורת: allOrders.filter((order) =>
          !order.isPackaged && order.product !== "אבן גיר"),
      };
  
      for (const truckType in ordersByTruckType) {
        if (Object.prototype.hasOwnProperty.call(ordersByTruckType, truckType)) {
          const orders = ordersByTruckType[truckType];
  
          for (const order of orders) {
            // Get client latitude and longitude
            const clientLatLng = await getLatLngFromAddress(order.clientAddress);
  
            const destinations = [{ latitude: clientLatLng.lat, longitude: clientLatLng.lng }];
            console.log("Destinations:", destinations);
  
            const travelTimes = await calculateTravelTime(COMPANY_LOCATION, destinations);
  
            let bestEmployee = null;
            for (const employee of employees) {
              if (employee.truckType === truckType &&
              (!bestEmployee || employee.totalDuration < bestEmployee.totalDuration)) {
                bestEmployee = employee;
              }
            }
  
            if (bestEmployee) {
              const travelTime = travelTimes[0].duration;
              bestEmployee.deliveries.push(order);
              bestEmployee.totalDuration += travelTime;
            } else {
              console.warn(`No available employee for truck type ${truckType} and order ${order.orderId}`);
            }
          }
        }
      }
  
      // Save assignments to Firestore
      for (const employee of employees) {
        if (employee.deliveries.length > 0) {
          const date = new Date().toISOString().split("T")[0]; // Get the current date (e.g., "2024-12-29")
      
          // Use the employeeDocId (Firestore document ID) for the employee
          const employeeDocId = employee.employeeDocId;
      
          // Reference to the "dailyDeliveries" subcollection
          const dailyDeliveriesRef = db.collection("Employees").doc(employeeDocId).collection("dailyDeliveries");
      
          // Clear existing deliveries in the subcollection
          const existingDeliveriesSnapshot = await dailyDeliveriesRef.get();
          const batch = db.batch(); // Use a batch to delete multiple documents efficiently
      
          existingDeliveriesSnapshot.forEach((doc) => {
            batch.delete(doc.ref);
          });
      
          // Commit the batch to delete all documents
          if (!existingDeliveriesSnapshot.empty) {
            await batch.commit();
            console.log(`Cleared previous deliveries for employee: ${employeeDocId}`);
          }
      
          // Add new deliveries to the "dailyDeliveries" subcollection
          for (const delivery of employee.deliveries) {
            await dailyDeliveriesRef.doc(`${date}-${delivery.orderId}`).set({
              ...delivery,
              date: date, // Add the current date to each order
            });
          }
      
          console.log(`Added new deliveries for employee: ${employeeDocId}`);
        }
      }
      
      
      console.log("Daily deliveries assigned and saved as subcollections under the employee document IDs.");
      
  
      console.log("Delivery assignments completed.");
    } catch (error) {
      console.error("Error assigning deliveries:", error);
      throw error;
    }
  };
  
  // Run the assignment function
  assignDeliveries().catch(console.error);


