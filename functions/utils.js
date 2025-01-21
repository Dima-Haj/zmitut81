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

const cache = {};
const optimizeRouteForDriverEfficiently = async (order, COMPANY_LOCATION, PREPARATION_TIME, CLIENT_WAITING_TIME, currentTime) => {
  const cacheKey = `${order.orderId}-${currentTime}`;
  // Check if route for this order has already been calculated to save time
  if (cache[cacheKey]) {
    return cache[cacheKey];
  }
  const optimizedRoute = await optimizeRouteForDriver(order, COMPANY_LOCATION, PREPARATION_TIME, CLIENT_WAITING_TIME, currentTime);
  cache[cacheKey] = optimizedRoute;
  return optimizedRoute;
};
const separateOrdersByTruckType = async () => {
  try {

    // const orderspostponed = await db.collection("PostponedDeliveries").get();
    const lateOrders = [];
    const newOrders = [];
    const allOrders = {
      פלטה: { small: [], big: [] },
      צובר: [],
      תפזורת: { double: [], regular: [] },
    };
    const clientsSnapshot = await db.collection("clients").get();

    for (const clientDoc of clientsSnapshot.docs) {
      const clientId = clientDoc.id;
      const clientData = clientDoc.data();
      const ordersSnapshot = await db
        .collection("clients")
        .doc(clientId)
        .collection("orders")
        .get();
    
      for (const orderDoc of ordersSnapshot.docs) {
        const order = orderDoc.data();
        const targetArray = order.status === 'באיחור' ? lateOrders : newOrders;
        targetArray.push({ clientId,
          clientAddress: clientData.address,
          clientPhone: clientData.phone,
          clientName: clientData.name, 
          orderId: orderDoc.id,
          ...order
         });
      }
    }
    
    
    if (lateOrders.length > 0) {
      for (const postponed of lateOrders) {
        await processOrderNewLate(postponed, allOrders);
      }
    } else {
      console.log("No postponed deliveries to save.");
    }
    if (newOrders.length > 0) {
      for (const order of newOrders) {
        await processOrderNewLate(order, allOrders);
      }
    } else {
      console.log("No New deliveries to save.");
    }

    return allOrders;
  } catch (error) {
    console.error("Error categorizing orders:", error);
    throw error;
  }
};
const processOrderNewLate = async (orderData, allOrders) => {
  console.log(orderData.clientAddress);
  if (orderData.isPackaged) {
    const limit = orderData.weightType === "ק\"ג" ? 12000 : 12;
    const bigLimit = orderData.weightType === "ק\"ג" ? 30000 : 30;

    if (orderData.weight <= limit) {
      allOrders.פלטה.small.push(orderData);
    } else if (orderData.weight <= bigLimit) {
      allOrders.פלטה.big.push(orderData);
    } else {
      const splitOrders = await splitOrder(orderData, 30000, "ק\"ג");
      splitOrders.forEach((splitOrder) =>
        (splitOrder.weight <= limit ? allOrders.פלטה.small : allOrders.פלטה.big
        ).push(splitOrder)
      );
    }
  } else if (["אבן גיר", "אבו גיר"].includes(orderData.product || orderData["Sub-Product"])) {
    const maxWeight = orderData.weightType === "טון" ? 36 : 360000;
    if (orderData.weight > maxWeight) {
      const splitOrders = await splitOrder(orderData, 36, "טון");
      allOrders.צובר.push(...splitOrders);
    } else {
      allOrders.צובר.push(orderData);
    }
  } else {
    const regularLimit = orderData.weightType === "טון" ? 20 : 20000;
    const doubleLimit = orderData.weightType === "טון" ? 40 : 40000;

    if (orderData.weight <= regularLimit) {
      allOrders.תפזורת.regular.push(orderData);
    } else if (orderData.weight <= doubleLimit) {
      allOrders.תפזורת.double.push(orderData);
    } else {
      const splitOrders = await splitOrder(orderData, 40, "טון");
      splitOrders.forEach((splitOrder) => {
        console.log(splitOrder.weight);
      });
      
      splitOrders.forEach((splitOrder) =>
        (splitOrder.weight <= regularLimit ? allOrders.תפזורת.regular : allOrders.תפזורת.double
        ).push(splitOrder)
      );
    }
  }
};


const processOrders = async () => {
    try {
        await assignDeliveries().then(() => {
          console.log("Completed delivery assignments");
        }).catch((error) => {
          console.error("Error in assignDeliveries:", error);
        });
    } catch (error) {
      console.error("Error processing orders:", error);
    }
  };
  
  
// Company Location (צמיתות 81 בע"ם)
const COMPANY_LOCATION = {latitude: 32.849758840523386,
  longitude: 35.17350796263602};

    const assignDeliveries = async () => {
    try {
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
  
      const allOrders = await separateOrdersByTruckType();
      // Group orders by truck type
      const ordersByTruckType = {
        פלטה: {
          small: allOrders.פלטה.small.sort((a, b) => (a.status === "באיחור" && b.status !== "באיחור" ? -1 : 0)),
          big: allOrders.פלטה.big.sort((a, b) => (a.status === "באיחור" && b.status !== "באיחור" ? -1 : 0)),
        },
        צובר: allOrders.צובר.sort((a, b) => (a.status === "באיחור" && b.status !== "באיחור" ? -1 : 0)),
        תפזורת: {
          regular: allOrders.תפזורת.regular.sort((a, b) => (a.status === "באיחור" && b.status !== "באיחור" ? -1 : 0)),
          double: allOrders.תפזורת.double.sort((a, b) => (a.status === "באיחור" && b.status !== "באיחור" ? -1 : 0)),
        },
      };
      
      // Process each truck type and subtype
      for (const truckType in ordersByTruckType) {
        if (Object.prototype.hasOwnProperty.call(ordersByTruckType, truckType)) {
          const subtypes = ordersByTruckType[truckType];
          // Handle subtypes for פלטה and תפזורת
          if (truckType === "פלטה" || truckType === "תפזורת") {
            for (const subtype in subtypes) {
              if (Object.prototype.hasOwnProperty.call(subtypes, subtype)) {
                const orders = subtypes[subtype];
                let newsubtype = "גדול";
                if (subtype === 'regular' || subtype === 'small') {
                  newsubtype = 'קטן';
                }

                const truckEmployees = employees.filter(
                  (e) => e.truckType === truckType && e.truckSize === newsubtype
                );
                console.log("orders: ", +subtypes.subtype);
                console.log("length of orders:", +orders.length);
                console.log("length of employees: ", +truckEmployees.length);
                if (orders.length === 0 || truckEmployees.length === 0) {
                  continue;
                }

                // Assign orders to minimize drivers and balance workload
                const assignments = await balanceOrdersAmongDrivers(orders, truckEmployees);

                // Further processing for assignments (same logic as before)
                for (const assignment of assignments) {
                  const driver = truckEmployees.find(
                    (e) => e.employeeDocId === assignment.driverId
                  );
                  if (!driver) continue;

                  // Process driver routes and postponed orders (same logic as before)

                  const postponed = await processDriverAssignments(driver, assignment.orders);
                  if (postponed.length != 0) {
                    postponedDeliveries.push(...postponed);
                  }
                }
              }
            }
          } else {
            // Handle צובר
            const orders = subtypes;

            const truckEmployees = employees.filter((e) => e.truckType === truckType);
            console.log("length of employees even geer: ", +truckEmployees.length);


            if (orders.length === 0 || truckEmployees.length === 0) {
              continue;
            }

            const assignments = await balanceOrdersAmongDrivers(orders, truckEmployees);

            for (const assignment of assignments) {
              const driver = truckEmployees.find((e) => e.employeeDocId === assignment.driverId);
              if (!driver) continue;

              const postponed = await processDriverAssignments(driver, assignment.orders);
              if (postponed.length != 0) {
                postponedDeliveries.push(...postponed);
              }
            }
          }
        }
      }

      // Save assignments to Firestore
      for (const driver of employees) {
        const dailyDeliveriesRef = await db
        .collection("Employees")
        .doc(driver.employeeDocId)
        .collection("dailyDeliveries");

      const batch = db.batch();
      const existingDeliveriesSnapshot = await dailyDeliveriesRef.get();

      existingDeliveriesSnapshot.forEach((doc) => batch.delete(doc.ref));
      if (!existingDeliveriesSnapshot.empty) await batch.commit();
      console.log("Batch operations committed.");
        if (driver.deliveries.length > 0) {
          const date = new Date().toISOString().split("T")[0];
          for (const delivery of driver.deliveries) {
            await dailyDeliveriesRef.doc(`${date}-${delivery.orderId}`).set({
                ...delivery,
              date,
            });
          }
        }
      }
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
        }

        const existingOrdersPostponed = await postponedRef.get();
        const batch = db.batch();

        existingOrdersPostponed.forEach((doc) => batch.delete(doc.ref));
        if (!existingOrdersPostponed.empty) await batch.commit();
    
        console.log("All documents in PostponedDeliveries have been deleted.");
        // Create an array of promises to save all postponed orders to the PostponedDeliveries collection
        if (postponedDeliveries.length > 0) {
        const promises = postponedDeliveries.map((postponed) => {
          // Create a new object with the updated status
          const updatedPostponed = {
              ...postponed, // spread existing properties
              status: "באיחור", // update status to "באיחור"
              date: nextDay, // set the date
          };
      
          console.log("Saving postponed order:", updatedPostponed.orderId);
      
          return postponedRef.doc(`${nextDay}-${updatedPostponed.orderId}`).set(updatedPostponed);
      });  
      
    
        // Wait for all promises to resolve
        await Promise.all(promises);
        console.log("All postponed orders saved successfully.");
         }
        } catch (error) {
        console.error("Error saving postponed deliveries:", error);
        }
  
  
      console.log("Delivery assignments completed.");
    } catch (error) {
      console.error("Error assigning deliveries:", error);
    }
  };
  
  processOrders();

  const processDriverAssignments = async (driver, assignedOrders) => {
            const PREPARATION_TIME = 30; // 30 minutes in seconds
            const CLIENT_WAITING_TIME = 30; // 30 minutes in seconds
            const START_TIME = DateTime.now().setZone('Asia/Jerusalem').startOf('day').plus({ days: 1, hours: 8 });
            const queue = new PriorityQueue((a, b) => {
              // Prioritize states with more late orders
              if (a.lateOrderCount !== b.lateOrderCount) {
                return b.lateOrderCount - a.lateOrderCount; // More late orders come first
              }
              // If both have the same number of late orders, prefer the one with more hours
              if (a.regularRoute.length === b.regularRoute.length) {
                return b.totalDeliveryTime - a.totalDeliveryTime; // Prefer longer routes
              }
              // Otherwise, prefer routes with more orders
              return b.regularRoute.length - a.regularRoute.length;
            });
      
            const visited = new Set(); // Track visited states to avoid redundant calculations
            const lateOrders = assignedOrders.filter((order) => order.status === "באיחור");
            const newOrders = assignedOrders.filter((order) => order.status !== "באיחור");
      
            console.log("New Orders length: ", newOrders.length);
            console.log("Late Orders length: ", lateOrders.length);
      
            let optimalRoute = [];
            let optimalPostponedRoute = []; // Store all postponed orders
            let maxOrders = 0;
            let maxDeliveryTime = 0; // Track the longest delivery time for routes with the same number of orders
            let maxLateOrders = 0; // Track the maximum number of late orders in a route
      
            let currentTime = Math.floor(START_TIME.toSeconds()); // Unix time in seconds
      
            // Enqueue initial state with all orders
            queue.enqueue({
              regularRoute: [],
              postponedRoute: [],
              costHours: 0,
              costMinutes: 0,
              totalDeliveryTime: 0, // Track total delivery time for the route
              remainingOrders: [...lateOrders, ...newOrders], // Combine late and new orders
              lateOrderCount: lateOrders.length, // Track the number of late orders in the remainingOrders
              currentTime: currentTime,
            });
      
            console.log("Queue size before processing: ", queue.size());
      
            // Process all orders in a single loop
            while (!queue.isEmpty()) {
              const { regularRoute, postponedRoute, costHours, costMinutes, totalDeliveryTime, remainingOrders, lateOrderCount, currentTime } = queue.dequeue();
              console.log('Queue size:', queue.size()); // Check queue size after dequeue
      
              const stateId = JSON.stringify({
                regularRoute: regularRoute.map((order) => order.orderId),
                postponedRoute: postponedRoute.map((order) => order.orderId), // Include postponedRoute in stateId
                costHours,
                costMinutes,
                remainingOrders: remainingOrders.map((order) => order.orderId),
                currentTime,
              });
      
              if (visited.has(stateId)) {
                continue;
              }
              visited.add(stateId);
      
              // Track the best route
              if (
                lateOrderCount > maxLateOrders || // Prefer routes with more late orders
                (lateOrderCount === maxLateOrders && regularRoute.length > maxOrders) || // If same late orders, prefer more orders
                (lateOrderCount === maxLateOrders && regularRoute.length === maxOrders && ((totalDeliveryTime > maxDeliveryTime) || (optimalPostponedRoute.length < postponedRoute.length))) 
              ) {
                maxLateOrders = lateOrderCount;
                maxOrders = regularRoute.length;
                maxDeliveryTime = totalDeliveryTime;
                optimalRoute = regularRoute;
                optimalPostponedRoute = postponedRoute; // Update the postponed orders
                console.log("Updated optimalPostponedRoute:", optimalPostponedRoute.length);
              }
      
              // Try each remaining order and add to the route
              for (const [index, order] of remainingOrders.entries()) {
                const optimizedRoute = await optimizeRouteForDriverEfficiently(order, COMPANY_LOCATION, PREPARATION_TIME, CLIENT_WAITING_TIME, currentTime);
      
                const deliveryTime =
                  optimizedRoute[0].totalDeliveryTime.hours * 3600 +
                  optimizedRoute[0].totalDeliveryTime.minutes * 60;
      
                const newTime = currentTime + deliveryTime;
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
                  console.log("Order postponed:", order.orderId);
                  queue.enqueue({
                    regularRoute,
                    postponedRoute: newPostponedRoute,
                    costHours,
                    costMinutes,
                    totalDeliveryTime, // Keep the same total delivery time
                    remainingOrders: remainingOrders.filter((_, i) => i !== index),
                    lateOrderCount: remainingOrders.filter((o) => o.status === "באיחור").length, // Update lateOrderCount
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
                    totalDeliveryTime: totalDeliveryTime + deliveryTime, // Update total delivery time
                    remainingOrders: newRemainingOrders,
                    lateOrderCount: newRemainingOrders.filter((o) => o.status === "באיחור").length, // Update lateOrderCount
                    currentTime: newTime,
                  });
                }
              }
            }
            // Save the optimal route to the driver's deliveries
            for (const order of optimalRoute) {
              const optimizedRoute = await optimizeRouteForDriverEfficiently(order, COMPANY_LOCATION, PREPARATION_TIME, CLIENT_WAITING_TIME, currentTime);
              driver.deliveries.push(...optimizedRoute);
      
              currentTime += optimizedRoute[0].totalDeliveryTime.hours * 3600 + optimizedRoute[0].totalDeliveryTime.minutes * 60;
            }
      return optimalPostponedRoute;
  };

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

    const EmployeesSnapshot = await db.collection("Employees").get();
  
    for (const EmployeeDoc of EmployeesSnapshot.docs) {
      const EmployeeId = EmployeeDoc.id;
  
      const shiftSnapshot = await db
        .collection("Employees")
        .doc(EmployeeId)
        .collection("work_shifts")
        .get();
  
  
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
        // console.log("current Month: ", currentmon);
        if (start.getMonth() != currentmon) {
          continue;
        }
  
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
