/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

/* eslint-disable no-unused-vars */

const {onRequest} = require("firebase-functions/v2/https");
const {getFirestore} = require("firebase-admin/firestore");
const {initializeApp} = require("firebase-admin/app");
const functions = require("firebase-functions");

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

initializeApp();

exports.initGpsUnit = functions.https.onCall(async (request, response) => {
  const {name, userId, macAddress} = request.data;
  const db = getFirestore();
  const gpsUnitRef = db.collection("users").doc(userId)
      .collection("gpsUnits").doc(macAddress);

  try {
    await gpsUnitRef.set({
      name, macAddress, updatedAt: new Date(), createdAt: new Date(),
      latitude: "0", longitude: "0", streetName: "Unknown Street",
    }, {merge: true});

    return {message: `GPS unit ${macAddress} upserted successfully.`};
  } catch (error) {
    console.error("Error upserting GPS unit:", error);
    throw new functions.https.HttpsError("internal", "Internal Server Error");
  }
});

exports.postGpsData = onRequest(async (request, response) => {
  const {userId, gpsUnitId, latitude, longitude} = request.body;
  const db = getFirestore();
  const gpsUnitRef = db
      .collection("users")
      .doc(userId)
      .collection("gpsUnits")
      .doc(gpsUnitId);

  let streetName = "Unknown Street";

  try {
    const res = await fetch(`https://nominatim.openstreetmap.org/reverse?format=json&lat=${latitude}&lon=${longitude}`);
    if (res.ok) {
      const data = await res.json();
      streetName = data.display_name || "Unknown Street";
    } else {
      console.error("Error fetching street name: HTTP", res.status);
    }
  } catch (error) {
    console.error("Error fetching street name", error);
  }

  const gpsDataRef = gpsUnitRef.collection("gpsData").doc();
  const batch = db.batch();

  batch.update(gpsUnitRef, {
    latitude, longitude, streetName, updatedAt: new Date(),
  });

  batch.set(gpsDataRef, {
    latitude, longitude, streetName, timestamp: new Date(),
  });

  try {
    await batch.commit();
    response.status(200).send("OK");
  } catch (error) {
    console.error("Error committing batch:", error);
    response.status(500).send("Internal Server Error");
  }
});
