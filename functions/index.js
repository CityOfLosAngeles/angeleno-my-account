
const { onRequest } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");
const express = require("express");
const app = express();

admin.initializeApp();

const {
  updateUser,
  updatePassword,
  enrollOTP,
  confirmOTP,
  authMethods,
  unenrollMFA
} = require("./api/auth0");

const {
  corsProxyAutofill,
  corsProxyPlaceDetails
} = require("./api/maps")

app.use(express.json());

app.post("/updateUser", updateUser);
app.post("/updatePassword", updatePassword);
app.post("/enrollOTP", enrollOTP);
app.post("/confirmOTP", confirmOTP);
app.post("/authMethods", authMethods);
app.post("/unenrollMFA", unenrollMFA);

app.get("/corsProxyAutofill", corsProxyAutofill);
app.get("/corsProxyPlaceDetails", corsProxyPlaceDetails);

exports.auth0api = onRequest(app);
