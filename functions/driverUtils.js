/**
 * Balances orders among drivers to distribute workload evenly.
 * @param {Array<Object>} orders - List of orders to be distributed.
 * @param {Array<Object>} drivers - List of drivers available for delivery.
 * @return {Array<Object>} An array of assignments, each containing a driver ID and their assigned orders.
 */
const balanceOrdersAmongDrivers = (orders, drivers) => {
    console.log(orders.length);
    const assignments = drivers.map((d) => ({driverId: d.employeeDocId, orders: []}));
    orders.sort((a, b) => b.weight - a.weight); // Assign heavier orders first
  
    for (const order of orders) {
      const driver = assignments.reduce((a, b) => (a.orders.length <= b.orders.length ? a : b));
      driver.orders.push(order);
    }
    console.log("Assignments before enqueuing:", assignments);
    return assignments;
  };
  
  
  // Export the function for use in other files
  module.exports = {
    balanceOrdersAmongDrivers,
  };
  
