const {onRequest} = require("firebase-functions/v2/https");
const axios = require("axios");
const admin = require("firebase-admin");
const {User} = require("./models/user");

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

exports.updateUser = onRequest( async (req, res) => {
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

  if (user.state) {
    primaryAddress["state"] = user.state;
  }

  if (user.city) {
    primaryAddress["city"] = user.city;
  }

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

exports.updatePassword = onRequest( async (req, res) => {
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
