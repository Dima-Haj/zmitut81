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
    if (order.weightType != weightType) {
      if (weightType == 'טון') {
          maxWeight *=1000;
      } else {
        maxWeight /=1000;
      }
    }
    let splitCount = 1;
    const orderId = order.orderId;
    while (remainingWeight > 0) {
      const currentWeight = Math.min(remainingWeight, maxWeight);
      const splitOrder = {
        ...order,
        weight: currentWeight,
        orderId: orderId + " " +splitCount, 
        originalOrderId: orderId,
        splitNumber: splitCount,
      };
      splitOrders.push(splitOrder);
      remainingWeight -= currentWeight;
      splitCount += 1;
    }
  
    return splitOrders;
  };
  
// Export the function for use in other files
module.exports = {
    splitOrder,
  };
