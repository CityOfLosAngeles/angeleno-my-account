const {onRequest} = require("firebase-functions/v2/https");
const admin = require("firebase-admin");
const express = require("express");

admin.initializeApp();
const auth0 = express();

const {
  updateUser,
  updatePassword,
  enrollOTP,
  confirmOTP,
  authMethods,
  unenrollMFA
} = require("./api/auth0");

auth0.use(express.json());

auth0.post("/updateUser", updateUser);
auth0.post("/updatePassword", updatePassword);
auth0.post("/enrollOTP", enrollOTP);
auth0.post("/confirmOTP", confirmOTP);
auth0.post("/authMethods", authMethods);
auth0.post("/unenrollMFA", unenrollMFA);

exports.auth0 = onRequest(auth0);
