const admin = require("firebase-admin");
const { DateTime } = require('luxon');
const { splitOrder } = require('./orderUtils');
const { balanceOrdersAmongDrivers } = require('./driverUtils');
const { optimizeRouteForDriver } = require('./routeOptimizer');

admin.initializeApp({
  credential: admin.credential.cert(require("./config/serviceAccountKey.json")),
});

const db = admin.firestore();

/**
 * Checks if a user is a manager.
 * @return {Promise<boolean>} Returns true if the user is a manager
 */


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
separateOrdersByTruckType();

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
            const START_TIME = DateTime.now().setZone('Asia/Jerusalem').startOf('day').plus({ days: 1, hours: 8 });
            let currentTime = Math.floor(START_TIME.toSeconds()); // Unix time in seconds
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
