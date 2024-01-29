const { onRequest } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");
const axios = require("axios");
const express = require("express");

admin.initializeApp();
const maps = express();

maps.use(express.json());

const corsProxyAutofill = onRequest(async (req, res) => {
  //const { url } = req.query;
  console.log("We are in corsProxyAutofill");
  const { url, types, language, sessiontoken, key } = req.query;
  //console.log('the url is ' + url + " : " +sessiontoken+ " : "+key+" : "+language + " : "+types);

  const reconstructedString =
    url +
    "&types=" +
    types +
    "&language=" +
    language +
    "&key=" +
    key +
    "&sessiontoken=" +
    sessiontoken;
  console.log("The reconstructed string is: \n" + reconstructedString);

  try {
    // Proxy the actual request
    const response = await axios.get(reconstructedString, {
      withCredentials: true, // Forward cookies for authenticated requests
    });

    res.status(response.status).send(response.data);
  } catch (error) {
    console.error("Error during proxy request:", error);
    res.status(500).send("Error fetching data");
  }
});

const corsProxyPlaceDetails = onRequest(async (req, res) => {
  //const { url } = req.query;
  console.log("We are in corsProxyPlaceDetails");
  const { url, place_id, fields, sessiontoken, key } = req.query;
  console.log(
    "the url: " +
      url +
      " \nsessiontoken: " +
      sessiontoken +
      " \nkey: " +
      key +
      " \nfields: " +
      fields +
      " \nplace_id: " +
      place_id
  );

  const reconstructedString =
    url + "&fields=" + fields + "&key=" + key + "&sessiontoken=" + sessiontoken;
  console.log("The reconstructed string is: \n" + reconstructedString);

  try {
    // Proxy the actual request
    const response = await axios.get(reconstructedString, {
      withCredentials: true, // Forward cookies for authenticated requests
    });

    res.status(response.status).send(response.data);
  } catch (error) {
    console.error("Error during proxy request:", error);
    res.status(500).send("Error fetching data");
  }
});

maps.get("/corsProxyPlaceDetails", corsProxyPlaceDetails);
maps.get("/corsProxyAutofill", corsProxyAutofill);

exports.maps = onRequest(maps);
