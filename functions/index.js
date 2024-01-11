const {onRequest} = require("firebase-functions/v2/https");
const express = require("express");
const app = express();
const admin = require("firebase-admin");

admin.initializeApp();

const {
  updateUser,
  updatePassword,
  enrollOTP,
  confirmOTP,
  authMethods,
  unenrollMFA
} = require("./api/auth0");

app.use(express.json());

app.post("/updateUser", updateUser);
app.post("/updatePassword", updatePassword);
app.post("/enrollOTP", enrollOTP);
app.post("/confirmOTP", confirmOTP);
app.post("/authMethods", authMethods);
app.post("/unenrollMFA", unenrollMFA);

const auth0Api = onRequest(app);

module.exports = {
  auth0Api
};
