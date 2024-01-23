const { onRequest } = require("firebase-functions/v2/https");
const axios = require("axios");
const admin = require("firebase-admin");
const { User } = require("./models/user");

admin.initializeApp();


const {
  auth0ClientId,
  auth0ClientSecret,
  auth0Domain
} = process.env;


const getAccessToken = async () => {
  const options = {
    "Content-Type": "application/x-www-form-urlencoded"
  };

  const body = {
    "grant_type": "client_credentials",
    "client_id": auth0ClientId,
    "client_secret": auth0ClientSecret,
    "audience": `https://${auth0Domain}/api/v2/`
  };

  const request = await axios.post(
    `https://${auth0Domain}/oauth/token`,
    body, {
    headers: options
  }
  );

  if (request.status === 200) {
    return request.data.access_token;
  }
};

exports.updateUser = onRequest(async (req, res) => {
  let user;

  try {
    user = Object.assign(new User, req.body);
  } catch (err) {
    console.error(err);
    return res.send(400);
  }

  const updatedUserObject = {};

  if (user.firstName) {
    updatedUserObject["given_name"] = user.firstName;
  }

  if (user.lastName) {
    updatedUserObject["family_name"] = user.lastName;
  }

  const primaryAddress = {};
  if (user.zip) {
    primaryAddress["zip"] = user.zip;
  }

  if (user.address) {
    primaryAddress["address"] = user.address;
  }

  if (user.address2) {
    primaryAddress["address2"] = user.address2;
  }

  if (user.state) {
    primaryAddress["state"] = user.state;
  }

  if (user.city) {
    primaryAddress["city"] = user.city;
  }
  console.log(user);
  const metaAddresses = user.metadata["addresses"];

  if (metaAddresses) {
    metaAddresses["primary"] = primaryAddress;
  } else {
    user.metadata = {
      "addresses": {
        "primary": primaryAddress
      }
    };
  }

  user.metadata["phone"] = user.phone;
  updatedUserObject["user_metadata"] = user.metadata;

  const updateUserUrl = `https://${auth0Domain}/api/v2/users/${user.userId}`;
  const token = await getAccessToken();
  const headers = {
    "Content-Type": "application/json",
    "Accept": "application/json",
    "Authorization": `Bearer ${token}`
  };

  try {
    const request = await axios.patch(updateUserUrl, updatedUserObject, {
      headers
    });

    if (request.status === 200) {
      return res.status(200).send(request.data);
    } else {
      return res.sendStatus(request.status);
    }
  } catch (err) {
    console.log(err);
    return res.send(err);
  }
});

exports.updatePassword = onRequest(async (req, res) => {
  const body = req.body;

  try {
    const passwordValidationRequest = {
      method: "POST",
      url: `https://${auth0Domain}/oauth/token`,
      headers: {
        "Content-Type": "application/x-www-form-urlencoded"
      },
      data: new URLSearchParams({
        "grant_type": "password",
        "username": body.email,
        "password": body.oldPassword,
        "client_id": auth0ClientId,
        "client_secret": auth0ClientSecret,
        "audience": `https://${auth0Domain}/api/v2/`,
        "scope": "openid",
      })
    };

    const validateResponse = await axios.request(passwordValidationRequest);

    if (validateResponse.status === 200) {
      const auth0Token = await getAccessToken();
      const passwordUpdateRequest = {
        method: "PATCH",
        url: `https://${auth0Domain}/api/v2/users/${body.userId}`,
        headers: {
          "Content-Type": "application/json",
          "authorization": `Bearer ${auth0Token}`
        },
        data: {
          password: body.newPassword,
          connection: "Username-Password-Authentication"
        }
      };

      const updateResponse = await axios.request(passwordUpdateRequest);

      if (updateResponse.status === 200) {
        res.status(200).send();
        return;
      }
    }
  } catch (err) {
    console.error(`Error: ${err.message}`);

    const {
      error_description,
      message
    } = err?.response?.data

    res.status(500).send(message || error_description || 'Error encountered');
    return;
  }
});

const functions = require('firebase-functions');
const cors = require('cors')({ origin: true }); // Enable CORS for all origins

exports.corsProxyAutofill = functions.https.onRequest(async (req, res) => {
  //const { url } = req.query;
  console.log('We are in corsProxyAutofill');
  const { url, types, language, sessiontoken, key } = req.query;
  //console.log('the url is ' + url + " : " +sessiontoken+ " : "+key+" : "+language + " : "+types);
 
 const reconstructedString = url+"&types="+types+"&language="+language+"&key="+key+"&sessiontoken="+sessiontoken;
 console.log('The reconstructed string is: \n'+reconstructedString); 

  try {
      // Handle preflight request
      res.set('Access-Control-Allow-Origin', '*');
      res.set('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE');
      res.set('Access-Control-Allow-Headers', 'Content-Type');


    // Proxy the actual request
    const response = await axios.get(reconstructedString, {
      withCredentials: true, // Forward cookies for authenticated requests
    });

    res.set('Access-Control-Allow-Origin', '*'); // Set CORS headers for the response
    res.status(response.status).send(response.data);

  } catch (error) {
    console.error('Error during proxy request:', error);
    res.status(500).send('Error fetching data');
  }
});

exports.corsProxyPlaceDetails = functions.https.onRequest(async (req, res) => {
  //const { url } = req.query;
  console.log('We are in corsProxyPlaceDetails');
  const { url, place_id, fields, sessiontoken, key } = req.query;
  console.log('the url: ' + url + " \nsessiontoken: " +sessiontoken+ " \nkey: "+key+" \nfields: "+fields + " \nplace_id: "+place_id);
 
 const reconstructedString = url+"&fields="+fields+"&key="+key+"&sessiontoken="+sessiontoken;
 console.log('The reconstructed string is: \n'+reconstructedString); 

  try {
      // Handle preflight request
      res.set('Access-Control-Allow-Origin', '*');
      res.set('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE');
      res.set('Access-Control-Allow-Headers', 'Content-Type');

    // Proxy the actual request
    const response = await axios.get(reconstructedString, {
      withCredentials: true, // Forward cookies for authenticated requests
    });

    res.set('Access-Control-Allow-Origin', '*'); // Set CORS headers for the response
    res.status(response.status).send(response.data);

  } catch (error) {
    console.error('Error during proxy request:', error);
    res.status(500).send('Error fetching data');
  }
});
