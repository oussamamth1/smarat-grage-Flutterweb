import { initializeApp } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";
import * as functions from "firebase-functions/v2";

// Initialize Firebase Admin
initializeApp();
const db = getFirestore();

// HTTP function
export const helloWorld = functions.https.onRequest((req, res) => {
    res.send("Hello from Firebase!");
});

// Firestore trigger (on document creation in 'bike_parts')
export const stockChange = functions.firestore.onDocumentCreated(
    "bike_parts/{partId}",
    async (event) => {
        const newPart = event.data;
        console.log("New part added:", newPart);
    }
);
