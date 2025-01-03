const functions = require("firebase-functions");
const {assignDeliveries, separateOrdersByTruckType} = require("./utils");

exports.scheduleDailyTasks = functions.https.onRequest(async (req, res) => {
  try {
    console.log("Running scheduled tasks...");

    console.log("Separating orders by truck type...");
    await separateOrdersByTruckType();

    console.log("Assigning deliveries...");
    await assignDeliveries();

    console.log("Scheduled tasks completed successfully.");
    res.status(200).send("Scheduled tasks completed successfully.");
  } catch (error) {
    console.error("Error running scheduled tasks:", error);
    res.status(500).send("Error running scheduled tasks.");
  }
});
