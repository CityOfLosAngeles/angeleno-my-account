const {onRequest} = require("firebase-functions/v2/https");
const admin = require("firebase-admin");

const {
  auth0
 } = require("./auth0/auth0");

 const {
  maps
} = require("./maps/maps");

admin.initializeApp();

exports.auth0api = onRequest(auth0);
exports.maps = onRequest(maps);