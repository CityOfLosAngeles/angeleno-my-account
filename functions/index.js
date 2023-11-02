const {onRequest} = require("firebase-functions/v2/https");
const axios = require("axios");
const admin = require("firebase-admin");

admin.initializeApp();

const {
  auth0ClientId,
  auth0ClientSecret,
  auth0Domain
} = process.env;

class User {
  constructor(
      userId,
      email,
      firstName,
      lastName,
      address,
      city,
      state,
      zip,
      phone,
      metadata
  ) {
    this.userId = userId,
    this.email = email,
    this.firstName = firstName,
    this.lastName = lastName,
    this.address = address,
    this.city = city,
    this.state = state,
    this.zip = zip,
    this.phone = phone,
    this.metadata = metadata;
  }
}

const getAccesToken = async () => {
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
  const token = await getAccesToken();
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
