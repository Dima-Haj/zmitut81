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
        console.log("No postponed deliveries to save.");

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

    const categorizedOrdersRef = await db.collection("categorizedOrders");

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
        console.log("Starting to process PostponedDeliveries:", new Date().toISOString());
        await separateOrdersByTruckType();
        console.log("Completed processing PostponedDeliveries:", new Date().toISOString());
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
            console.log("Starting assignment for driver:", driver.employeeDocId);

            const START_TIME = DateTime.now().setZone('Asia/Jerusalem').startOf('day').plus({ days: 1, hours: 8 });
            const queue = new PriorityQueue((a, b) => a.cost - b.cost); // Min-heap based on cost
            const visited = new Set(); // Track visited states to avoid redundant calculations
            const lateOrders = assignment.orders.filter((order) => order.status === "באיחור");
            const newOrders = assignment.orders.filter((order) => order.status === "חדשה");
      
            let currentTime = Math.floor(START_TIME.toSeconds()); // Unix time in seconds
            console.log("Queue enqueue for late orders...");

            // Prioritize Late Orders
            queue.enqueue({
              regularRoute: [],
              postponedRoute: [],
              costHours: 0,
              costMinutes: 0,
              remainingOrders: lateOrders,
              currentTime: currentTime,
            });
      
            let optimalRoute = [];
            let optimalPostponedRoute = [];
            let maxOrders = 0;
      
            // Handle late orders first using UCS (Uniform Cost Search)
            while (!queue.isEmpty()) {
              const { regularRoute, postponedRoute, costHours, costMinutes, remainingOrders, currentTime } = queue.dequeue();
      
              const stateId = JSON.stringify({
                regularRoute: regularRoute.map((order) => order.orderId),
                postponedRoute: postponedRoute.map((order) => order.orderId),
                costHours,
                costMinutes,
                remainingOrders: remainingOrders.map((order) => order.orderId),
                currentTime,
              });
      
              if (visited.has(stateId)) {
                continue;
              }
              visited.add(stateId);
      
              if (regularRoute.length > maxOrders || (regularRoute.length === maxOrders && remainingOrders.length === 0)) {
                maxOrders = regularRoute.length;
                optimalRoute = regularRoute;
                optimalPostponedRoute = postponedRoute; // Temporarily store postponed route
              }
              // console.log(stateId);
      
              // Try each remaining order and add to the route
              for (const [index, order] of remainingOrders.entries()) {
                // console.log("Optimizing route for order:", order.orderId);

                const optimizedRoute = await optimizeRouteForDriver(order, COMPANY_LOCATION, PREPARATION_TIME, CLIENT_WAITING_TIME, currentTime);
      
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
      
            // Handle new orders after the late orders are assigned
            queue.enqueue({
              regularRoute: optimalRoute,
              postponedRoute: optimalPostponedRoute,
              costHours: 0,
              costMinutes: 0,
              remainingOrders: newOrders,
              currentTime: currentTime,
            });
      
            // Recalculate the optimal route by considering new orders and maintaining late order constraints
            while (!queue.isEmpty()) {
              const { regularRoute, postponedRoute, costHours, costMinutes, remainingOrders, currentTime } = queue.dequeue();
      
              const stateId = JSON.stringify({
                regularRoute: regularRoute.map((order) => order.orderId),
                postponedRoute: postponedRoute.map((order) => order.orderId),
                costHours,
                costMinutes,
                remainingOrders: remainingOrders.map((order) => order.orderId),
                currentTime,
              });
      
              if (visited.has(stateId)) {
                continue;
              }
              visited.add(stateId);
      
              if (regularRoute.length > maxOrders || (regularRoute.length === maxOrders && postponedRoute.length > optimalPostponedRoute.length)) {
                maxOrders = regularRoute.length;
                optimalRoute = regularRoute;
                optimalPostponedRoute = postponedRoute;
              }
              // console.log(stateId);
      
              let bestCostHours = Infinity;
              let bestCostMinutes = Infinity;

              for (const [index, order] of remainingOrders.entries()) {
              // console.log("Optimizing route for order:", order.orderId);

                // Try inserting the order at different positions in the regular route
                for (let i = 0; i <= regularRoute.length; i++) {

                  const newRegularRoute = [...regularRoute.slice(0, i), order, ...regularRoute.slice(i)];
                  let newCostHours1 = 0;
                  let newCostMinutes1 = 0;
                  let newCurrentTime = currentTime;
      
                  // Recalculate the delivery times for each order in the updated regular route
                  for (let j = 0; j < newRegularRoute.length; j++) {

                    const optimizedRoute = await optimizeRouteForDriver(newRegularRoute[j], COMPANY_LOCATION, PREPARATION_TIME, CLIENT_WAITING_TIME, newCurrentTime);
      
                    const deliveryTime =
                      optimizedRoute[0].totalDeliveryTime.hours * 3600 +
                      optimizedRoute[0].totalDeliveryTime.minutes * 60;
      
                    newCurrentTime += deliveryTime;
                    newCostHours1 += optimizedRoute[0].totalDeliveryTime.hours;
                    newCostMinutes1 += optimizedRoute[0].totalDeliveryTime.minutes;
      
                    // Normalize minutes to hours
                    if (newCostMinutes1 >= 60) {
                      newCostHours1 += Math.floor(newCostMinutes1 / 60);
                      newCostMinutes1 = newCostMinutes1 % 60;
                    }
                  }

      
                  // Check if inserting the order at position 'i' exceeds 8 hours
                  if ((newCostHours1 < bestCostHours) || ((newCostHours1 === bestCostHours) && (newCostMinutes1 < bestCostMinutes))) {
                    if (newCostHours1 > 8 || (newCostHours1 === 8 && newCostMinutes1 > 0)) {
                      postponedRoute.push(order);
                    } else {
                      bestCostHours = newCostHours1;
                      bestCostMinutes = newCostMinutes1;
                      optimalRoute = newRegularRoute;
                    }
                  }
                }

                const newRemainingOrders = remainingOrders.filter((_, i) => i !== index);
                queue.enqueue({
                  regularRoute: optimalRoute,
                  postponedRoute: postponedRoute,
                  costHours: bestCostHours,
                  costMinutes: bestCostMinutes,
                  remainingOrders: newRemainingOrders,
                  currentTime: currentTime,
                });
              }
            }
            console.log("1) reached");
            // Save the deliveries to Firebase for this driver
            for (const order of optimalRoute) {
              const optimizedRoute = await optimizeRouteForDriver(order, COMPANY_LOCATION, PREPARATION_TIME, CLIENT_WAITING_TIME, currentTime);
              driver.deliveries.push(...optimizedRoute);
      
              currentTime += optimizedRoute[0].totalDeliveryTime.hours * 3600 + optimizedRoute[0].totalDeliveryTime.minutes * 60;
            }
          }
        }
      }
      
      console.log("2) reached");
      // Save assignments to Firestore
      for (const driver of employees) {
        if (driver.deliveries.length > 0) {
          const date = new Date().toISOString().split("T")[0];
          const dailyDeliveriesRef = await db
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
    if (postponedDeliveries.length > 0) {
        console.log("length is more than 0", postponedDeliveries.length);
        console.log("Postponed deliveries: ", postponedDeliveries);
        const nextDay = DateTime.now()
        .setZone('Asia/Jerusalem')
        .plus({ days: 2 })
        .startOf('day')
        .toISODate();
            
        try {
            const postponedRef = await db.collection("PostponedDeliveries");
        // First, update the status of each postponed delivery
        for (const postponedOrder of postponedDeliveries) {
            const orderRef = await db
            .collection("clients")
            .doc(postponedOrder.clientId)
            .collection("orders")
            .doc(postponedOrder.orderId);
    
            await orderRef.update({ status: "באיחור" });
            console.log("Order ${postponedOrder.orderId} marked as postponed.");
        }

        const existingOrdersPostponed = await postponedRef.get();
        const batch = db.batch();

        existingOrdersPostponed.forEach((doc) => batch.delete(doc.ref));
        if (!existingOrdersPostponed.empty) await batch.commit();
    
        console.log("All documents in PostponedDeliveries have been deleted.");
        // Create an array of promises to save all postponed orders to the PostponedDeliveries collection
        const promises = postponedDeliveries.map((postponed) => {
            console.log("Saving postponed order:", postponed.orderId);
            return postponedRef.doc('${nextDay}-${postponed.orderId}').set({
            ...postponed,
            date: nextDay,
            });
        });
    
        // Wait for all promises to resolve
        await Promise.all(promises);
        console.log("All postponed orders saved successfully.");
        } catch (error) {
        console.error("Error saving postponed deliveries:", error);
        }
    } else {
        console.log("No postponed deliveries to save.");
    }  
  
      console.log("Delivery assignments completed.");
    } catch (error) {
      console.error("Error assigning deliveries:", error);
    }
  };
  
  
  assignDeliveries().then(() => {
    console.log("Completed delivery assignments");
  }).catch((error) => {
    console.error("Error in assignDeliveries:", error);
  });

  const calculateMonthlyWorkHours = async () => {
    const currentDate = new Date();
  
    // Use Israel Standard Time (IST) for the current date
    const currentYear = currentDate.getFullYear();
    const currentMonth = currentDate.getMonth(); // Gets month number (0 = January, 1 = February, etc.)
    // Convert current month number to month name
    const monthNames = [
      "January", "February", "March", "April", "May", "June", 
      "July", "August", "September", "October", "November", "December"
    ];
    let currentmon = currentMonth - 1;
    let currentye = currentYear;
    if (currentmon < 0) {
      currentye-=1;
      currentmon = 11;
    }

    const monthName = monthNames[currentmon];
  
    // Calculate the first and last day of the previous month
    const firstDayOfPreviousMonth = new Date(currentYear, currentMonth - 1, 0);
    firstDayOfPreviousMonth.setHours(0, 0, 0, 0);
    const lastDayOfPreviousMonth = new Date(currentYear, currentMonth, 0);
    lastDayOfPreviousMonth.setHours(0, 0, 0, 0);
    const options = { timeZone: 'Asia/Jerusalem', hour12: false };
    const israelFirstDay = new Date(firstDayOfPreviousMonth.toLocaleString('en-US', options));
    const israelLastDay = new Date(lastDayOfPreviousMonth.toLocaleString('en-US', options));
    console.log("first Day of previous month: ", israelFirstDay);
    console.log("Last Day of previous month: ", israelLastDay);
      // Convert the Israel time to UTC for Firestore query
  const israelFirstDayUTC = new Date(israelFirstDay.toISOString());
  const israelLastDayUTC = new Date(israelLastDay.toISOString());

  console.log("Israel First Day in UTC:", israelFirstDayUTC);
  console.log("Israel Last Day in UTC:", israelLastDayUTC);
  
    const EmployeesSnapshot = await db.collection("Employees").get();
  
    for (const EmployeeDoc of EmployeesSnapshot.docs) {
      const EmployeeId = EmployeeDoc.id;
      console.log("Employee Id: ", EmployeeId);
  
      const shiftSnapshot = await db
        .collection("Employees")
        .doc(EmployeeId)
        .collection("work_shifts")
        .get();
  
      console.log("Reached here successfully ------");
  
      let totalTime = 0;
  
      // Calculate total worked hours and minutes
      for (const shiftDoc of shiftSnapshot.docs) {
        const shiftData = shiftDoc.data();
        
        // Parse start and end time directly from Firestore's Timestamp
        let start = 0;
        let end = 0;
        if (shiftData.start == null) {
          start = new Date(shiftData.startTime);
          end = new Date(shiftData.endTime);
        } else {
          start = new Date(shiftData.start);
          end = new Date(shiftData.end); 
        }
        console.log("current Month: ", currentmon);
        if (start.getMonth() != currentmon) {
          continue;
        }
        console.log("start Hour: ", start.getHours());
        console.log("end Hour: ", end.getHours());
        console.log("start Minutes: ", start.getMinutes());
        console.log("end Hour: ", end.getMinutes());
  
        // Calculate milliseconds worked
        totalTime += end - start;
      }
      let totalHoursWorked = Math.floor(totalTime / (1000 * 60 * 60)); // Convert to hours
      let totalMinutesWorked = Math.floor((totalTime % (1000 * 60 * 60)) / (1000 * 60)); // Convert remaining milliseconds to minutes
  
      // Handle overflow minutes (if minutes exceed 60, add them to hours)
      if (totalMinutesWorked >= 60) {
        const additionalHours = Math.floor(totalMinutesWorked / 60);
        totalHoursWorked += additionalHours;
        totalMinutesWorked = totalMinutesWorked % 60; // Keep the remainder as minutes
      }
  
      console.log("Total Hours Worked: ", totalHoursWorked);
      console.log("Total Minutes Worked: ", totalMinutesWorked);
  
      // Store the total hours and minutes worked in the monthlyWorkHours subcollection
      const monthlyWorkHoursRef = db
        .collection("Employees")
        .doc(EmployeeId)
        .collection("monthlyWorkHours")
        .doc(`${currentye}-${monthName}`); // Use the month name as the document ID
  
      await monthlyWorkHoursRef.set({
        totalHours: totalHoursWorked,
        totalMinutes: totalMinutesWorked,
        month: monthName,
        year: currentye,
      });
    }
  };
  
  calculateMonthlyWorkHours();
  

module.exports = {
  assignDeliveries,
  separateOrdersByTruckType,
  calculateMonthlyWorkHours,
};
