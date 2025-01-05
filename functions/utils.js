const admin = require("firebase-admin");
const { DateTime } = require('luxon');
const { splitOrder } = require('./orderUtils');
const { balanceOrdersAmongDrivers } = require('./driverUtils');
const { optimizeRouteForDriver } = require('./routeOptimizer');
const { PriorityQueue } = require("@datastructures-js/priority-queue");

admin.initializeApp({
  credential: admin.credential.cert(require("./config/serviceAccountKey.json")),
});

const db = admin.firestore();


/**
 * Categorizes orders by truck type and verifies the manager's access.
 * @return {Promise<Object>} An object categorizing the orders by truck type.
 * @throws Will throw an error if the user is not a manager.
 */

const separateOrdersByTruckType = async () => {
  try {

    const orderspostponed = await db.collection("PostponedDeliveries").get();

    const clientsSnapshot = await db.collection("clients").get();
    const allOrders = {
      פלטה: {small: [], big: []},
      צובר: [],
      תפזורת: {double: [], regular: []},
    };

    if (!orderspostponed.empty) {
        for (const postponedDoc of orderspostponed.docs) {
            const postponed = postponedDoc.data();

            if (postponed.isPackaged) {
                if (
                (postponed.weightType === "ק\"ג" && postponed.weight <= 12000) ||
                    (postponed.weightType === "טון" && postponed.weight <= 12)
                ) {
                allOrders.פלטה.small.push({
                    ...postponed,
                });
                } else {
                const splitOrders = await splitOrder(postponed, 12000, "ק\"ג");
                allOrders.פלטה.big.push(...splitOrders);
                }
            } else if (
                postponed.product === "אבן גיר" ||
                postponed["Sub-Product"] === "אבו גיר"
            ) {
                if (postponed.weight > 36) {
                const splitOrders = await splitOrder(postponed, 36, "טון");
                allOrders.צובר.push(...splitOrders);
                } else {
                allOrders.צובר.push({
                    ...postponed,
                });
                }
            } else {
                if (
                (postponed.weightType === "טון" && postponed.weight <= 20) ||
                    (postponed.weightType === "ק\"ג" && postponed.weight <= 20000)
                ) {
                allOrders.תפזורת.regular.push({
                    ...postponed,
                });
                } else if (
                (postponed.weightType === "טון" && postponed.weight <= 40) ||
                    (postponed.weightType === "ק\"ג" && postponed.weight <= 40000)
                ) {
                allOrders.תפזורת.double.push({
                    ...postponed,
                });
                }
            }
        }
        const batch = db.batch();

        orderspostponed.docs.forEach((doc) => {
          const docRef = db.collection("PostponedDeliveries").doc(doc.id);
          batch.delete(docRef);
        });
    
        await batch.commit();
        console.log("All documents in PostponedDeliveries have been deleted.");
    }
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
            if (!allOrders.פלטה.small.some((order) => order.orderId === orderDoc.id)) {
                allOrders.פלטה.small.push({
                    clientId,
                    orderId: orderDoc.id,
                    ...order,
                });
            }
          } else {
            const splitOrders = await splitOrder(order, 12000, "ק\"ג");
            allOrders.פלטה.big.push(...splitOrders);
          }
        } else if (
          order.product === "אבן גיר" ||
            order["Sub-Product"] === "אבו גיר"
        ) {
          if (!allOrders.צובר.some((order) => order.orderId === orderDoc.id)) {
            if (order.weight > 36) {
                const splitOrders = await splitOrder(order, 36, "טון");
                allOrders.צובר.push(...splitOrders);
            } else {
                allOrders.צובר.push({
                clientId,
                orderId: orderDoc.id,
                ...order,
                });
            }
        }
        } else {
          if (
            (order.weightType === "טון" && order.weight <= 20) ||
              (order.weightType === "ק\"ג" && order.weight <= 20000)
          ) {
            if (!allOrders.תפזורת.regular.some((order) => order.orderId === orderDoc.id)) {
                allOrders.תפזורת.regular.push({
                clientId,
                orderId: orderDoc.id,
                ...order,
                });
            }
          } else if (
            (order.weightType === "טון" && order.weight <= 40) ||
              (order.weightType === "ק\"ג" && order.weight <= 40000)
          ) {
            if (!allOrders.תפזורת.double.some((order) => order.orderId === orderDoc.id)) {
                allOrders.תפזורת.double.push({
                clientId,
                orderId: orderDoc.id,
                ...order,
                });
            }
          }
        }
      }
    }

    const categorizedOrdersRef = db.collection("categorizedOrders");

    await categorizedOrdersRef.doc("פלטה").set(allOrders.פלטה);

    await categorizedOrdersRef.doc("צובר").set({orders: allOrders.צובר});

    await categorizedOrdersRef.doc("תפזורת").set(allOrders.תפזורת);

    console.log("Categorized orders saved to Firestore.");
    return allOrders;
  } catch (error) {
    console.error("Error categorizing orders:", error);
    throw error;
  }
};

const processOrders = async () => {
    try {
      await separateOrdersByTruckType();
      console.log("Orders have been processed and categorized.");
    } catch (error) {
      console.error("Error processing orders:", error);
    }
  };
  
  processOrders();
  
// Company Location (צמיתות 81 בע"ם)
const COMPANY_LOCATION = {latitude: 32.849758840523386,
  longitude: 35.17350796263602};

    const assignDeliveries = async () => {
    try {
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
        פלטה: allOrders
          .filter((order) => order.isPackaged)
          .sort((a, b) => (a.status === "באיחור" && b.status !== "באיחור" ? -1 : 0)),
        צובר: allOrders
          .filter((order) => !order.isPackaged && order.product === "אבן גיר")
          .sort((a, b) => (a.status === "באיחור" && b.status !== "באיחור" ? -1 : 0)),
        תפזורת: allOrders
          .filter((order) => !order.isPackaged && order.product !== "אבן גיר")
          .sort((a, b) => (a.status === "באיחור" && b.status !== "באיחור" ? -1 : 0)),
      };
      
  
      for (const truckType in ordersByTruckType) {
        if (Object.prototype.hasOwnProperty.call(ordersByTruckType, truckType)) {
          const orders = ordersByTruckType[truckType];
          const truckEmployees = employees.filter((e) => e.truckType === truckType);
      
          if (orders.length === 0 || truckEmployees.length === 0) continue;
      
          // Assign orders to minimize drivers and balance workload
          const assignments = await balanceOrdersAmongDrivers(orders, truckEmployees);
      
          for (const assignment of assignments) {
            const driver = truckEmployees.find((e) => e.employeeDocId === assignment.driverId);
            if (!driver) continue;
      
            const START_TIME = DateTime.now().setZone('Asia/Jerusalem').startOf('day').plus({ days: 1, hours: 8 });
            const queue = new PriorityQueue((a, b) => a.cost - b.cost); // Min-heap based on cost
            const visited = new Set(); // Track visited states to avoid redundant calculations
            const lateOrders = assignment.orders.filter((order) => order.status === "באיחור");
            const newOrders = assignment.orders.filter((order) => order.status === "חדשה");
            const prioritizedOrders = [...lateOrders, ...newOrders];
            let currentTime = Math.floor(START_TIME.toSeconds()); // Unix time in seconds
      
            queue.enqueue({
              regularRoute: [],
              postponedRoute: [],
              costHours: 0,
              costMinutes: 0,
              remainingOrders: prioritizedOrders,
              currentTime: currentTime,
            });
      
            let optimalRoute = [];
            let optimalPostponedRoute = [];
            let maxOrders = 0;
      
            while (!queue.isEmpty()) {
              const {
                regularRoute,
                postponedRoute,
                costHours,
                costMinutes,
                remainingOrders,
                currentTime,
              } = queue.dequeue();

              const stateId = JSON.stringify({
                regularRoute: regularRoute.map((order) => order.orderId),
                postponedRoute: postponedRoute.map((order) => order.orderId),
                costHours,
                costMinutes,
                remainingOrders: remainingOrders.map((order) => order.orderId),
                currentTime,
              });
            
            
              // Skip if this state has already been visited
              if (visited.has(stateId)) {
                continue;
              }
            
              // Mark this state as visited
              visited.add(stateId);


              // Update optimal route if more orders are delivered
              if (regularRoute.length > maxOrders || (regularRoute.length == maxOrders && remainingOrders.length==0)) {
                maxOrders = regularRoute.length;
                optimalRoute = regularRoute;
                optimalPostponedRoute = postponedRoute; // Temporarily store postponed route
                console.log(stateId);
              }

              // Process each remaining order
              for (const [index, order] of remainingOrders.entries()) {
                const optimizedRoute = await optimizeRouteForDriver(
                  order,
                  COMPANY_LOCATION,
                  PREPARATION_TIME,
                  CLIENT_WAITING_TIME,
                  currentTime
                );
      
                const totalDeliveryTime =
                  optimizedRoute[0].totalDeliveryTime.hours * 3600 +
                  optimizedRoute[0].totalDeliveryTime.minutes * 60;
      
                const newTime = currentTime + totalDeliveryTime;
                let newCostHours = costHours + optimizedRoute[0].totalDeliveryTime.hours;
                let newCostMinutes = costMinutes + optimizedRoute[0].totalDeliveryTime.minutes;
      
                // Normalize minutes to hours
                if (newCostMinutes >= 60) {
                  newCostHours++;
                  newCostMinutes -= 60;
                }
      
                // If time exceeds limit, temporarily store the postponed route
                if (newCostHours > 8 || (newCostHours === 8 && newCostMinutes !== 0)) {
                  const newPostponedRoute = [...postponedRoute, order];
      
                  // Update order status for temporary storage
      
                  queue.enqueue({
                    regularRoute,
                    postponedRoute: newPostponedRoute,
                    costHours,
                    costMinutes,
                    remainingOrders: remainingOrders.filter((_, i) => i !== index),
                    currentTime,
                  });
                } else {
                  // Add to regular route
                  const newRoute = [...regularRoute, order];
                  const newRemainingOrders = remainingOrders.filter((_, i) => i !== index);
      
                  queue.enqueue({
                    regularRoute: newRoute,
                    postponedRoute,
                    costHours: newCostHours,
                    costMinutes: newCostMinutes,
                    remainingOrders: newRemainingOrders,
                    currentTime: newTime,
                  });
                }
              }
            }
      
            // Assign optimal route to the driver
            for (const order of optimalRoute) {
              const optimizedRoute = await optimizeRouteForDriver(
                order,
                COMPANY_LOCATION,
                PREPARATION_TIME,
                CLIENT_WAITING_TIME,
                currentTime
              );
      
              driver.deliveries.push(...optimizedRoute);
      
              currentTime +=
                optimizedRoute[0].totalDeliveryTime.hours * 3600 +
                optimizedRoute[0].totalDeliveryTime.minutes * 60;
            }
      
            // Add temporarily stored postponed routes to the postponed deliveries
            if (optimalPostponedRoute.length > 0) {
                console.log("-------------the length is: ", +optimalPostponedRoute.length);
              for (const postponedOrder of optimalPostponedRoute) {
                // Ensure the status in Firestore is updated
                const orderRef = db
                  .collection("clients")
                  .doc(postponedOrder.clientId)
                  .collection("orders")
                  .doc(postponedOrder.orderId);
      
                await orderRef.update({ status: "באיחור" });
                postponedDeliveries.push(postponedOrder);
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
        const nextDay = DateTime.now()
        .setZone('Asia/Jerusalem')
        .plus({ days: 2 })
        .startOf('day')
        .toISODate();
        const postponedRef = db.collection("PostponedDeliveries");
        console.log("-------------the length is: ", +postponedDeliveries.length);
        for (const postponed of postponedDeliveries) {
          await postponedRef.doc(`${nextDay}-${postponed.orderId}`).set({
            ...postponed,
            date: nextDay,
          });
        }
      }
    
      console.log("Delivery assignments completed.");
    } catch (error) {
      console.error("Error assigning deliveries:", error);
    }
  };
  
  
assignDeliveries().then().catch(console.error);
module.exports = {
  assignDeliveries,
  separateOrdersByTruckType,
};
