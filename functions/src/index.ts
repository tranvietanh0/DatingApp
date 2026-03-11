import * as admin from "firebase-admin";

admin.initializeApp();

export { onSwipeCreated } from "./onSwipe";
export { onMessageCreated } from "./onMessage";
export { cleanupExpiredMatches } from "./cleanupExpiredMatches";
