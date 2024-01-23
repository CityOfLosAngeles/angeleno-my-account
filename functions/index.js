const {onRequest} = require("firebase-functions/v2/https");
const express = require("express");
const app = express();
const admin = require("firebase-admin");

admin.initializeApp();

const {
  updateUser,
  updatePassword,
  enrollMFA,
  confirmMFA,
  authMethods,
  unenrollMFA
} = require("./api/auth0");

app.use(express.json());

app.post("/updateUser", updateUser);
app.post("/updatePassword", updatePassword);
app.post("/enrollMFA", enrollMFA);
app.post("/confirmMFA", confirmMFA);
app.post("/authMethods", authMethods);
app.post("/unenrollMFA", unenrollMFA);

exports.auth0api = onRequest(app);