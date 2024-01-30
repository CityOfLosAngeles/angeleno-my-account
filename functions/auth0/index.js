const {onRequest} = require("firebase-functions/v2/https");
const admin = require("firebase-admin");
const express = require("express");

admin.initializeApp();
const app = express();

const {
  updateUser,
  updatePassword,
  enrollMFA,
  confirmMFA,
  authMethods,
  unenrollMFA
} = require("./api/auth0");

app.use(express.json());

app.post("/auth0/updateUser", updateUser);
app.post("/auth0/updatePassword", updatePassword);
app.post("/auth0/enrollMFA", enrollMFA);
app.post("/auth0/confirmMFA", confirmMFA);
app.post("/auth0/authMethods", authMethods);
app.post("/auth0/unenrollMFA", unenrollMFA);

exports.auth0 = onRequest(app);
