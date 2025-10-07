// functions/src/index.ts (Node 20 / v5+)
import * as functions from "firebase-functions/v2";
import * as admin from "firebase-admin";

admin.initializeApp();

export const getParts = functions.https.onRequest(async (req, res) => {
  const snapshot = await admin.firestore().collection("bike_parts").get();
  const parts = snapshot.docs.map((doc) => doc.data());
  res.json(parts);
});
