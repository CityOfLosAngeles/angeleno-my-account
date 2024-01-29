const { onRequest } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");
const axios = require("axios");
const express = require("express");

admin.initializeApp();
const maps = express();

maps.use(express.json());

const corsProxyAutofill = onRequest(async (req, res) => {
 
});

const corsProxyPlaceDetails = onRequest(async (req, res) => {
 
});

maps.get("/corsProxyPlaceDetails", corsProxyPlaceDetails);
maps.get("/corsProxyAutofill", corsProxyAutofill);

exports.maps = onRequest(maps);
