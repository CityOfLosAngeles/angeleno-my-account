const {onRequest} = require("firebase-functions/v2/https");
const axios = require("axios");
const {User} = require("../models/user");

const {
  auth0Domain,
  auth0ClientId,
  auth0ClientSecret,
} = require("../utils/constants");

const {getAccessToken, authorizeUser} = require("../utils/auth0");

const updateUser = onRequest(async (req, res) => {
  let user;

  try {
    user = Object.assign(new User(), req.body);
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

  const metaAddresses = user.metadata["addresses"];

  if (metaAddresses) {
    metaAddresses["primary"] = primaryAddress;
  } else {
    user.metadata = {
      addresses: {
        primary: primaryAddress,
      },
    };
  }

  user.metadata["phone"] = user.phone;
  updatedUserObject["user_metadata"] = user.metadata;

  const updateUserUrl = `https://${auth0Domain}/api/v2/users/${user.userId}`;
  const token = await getAccessToken();
  const headers = {
    "Content-Type": "application/json",
    "Accept": "application/json",
    "Authorization": `Bearer ${token}`,
  };

  try {
    const request = await axios.patch(updateUserUrl, updatedUserObject, {
      headers,
    });

    if (request.status === 200) {
      return res.status(200).send(request.data);
    } else {
      return res.sendStatus(request.status);
    }
  } catch (err) {
    console.error(err);
    return res.send(err);
  }
});

const updatePassword = onRequest(async (req, res) => {
  const body = req.body;

  try {
    const validateResponse = await authorizeUser(body.email, body.oldPassword);

    if (validateResponse.status === 200) {
      const auth0Token = await getAccessToken();
      const passwordUpdateRequest = {
        method: "PATCH",
        url: `https://${auth0Domain}/api/v2/users/${body.userId}`,
        headers: {
          "Content-Type": "application/json",
          "Authorization": `Bearer ${auth0Token}`,
        },
        data: {
          password: body.newPassword,
          connection: "Username-Password-Authentication",
        },
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
      status = undefined,
      data: {error_description, message},
    } = err?.response;

    res
      .status(status || 500)
      .send(message || error_description || "Error encountered");
    return;
  }
});

const authMethods = onRequest(async (req, res) => {
  const body = req.body;

  try {
    const auth0Token = await getAccessToken();

    const config = {
      method: "get",
      maxBodyLength: Infinity,
      url: `https://${auth0Domain}/api/v2/users/${body.userId}/authentication-methods`,
      headers: {
        Accept: "application/json",
        Authorization: `Bearer ${auth0Token}`,
      },
    };

    const request = await axios.request(config);
    res.status(200).send(request.data);
  } catch (err) {
    console.error(err);
  }
});

const enrollOTP = onRequest(async (req, res) => {
  const body = req.body;

  try {
    const validateResponse = await authorizeUser(
      body.email,
      body.password,
      "/mfa/"
    );

    if (validateResponse.status === 200) {
      const mfaToken = validateResponse?.data?.access_token;

      const otpRequest = {
        method: "POST",
        url: `https://${auth0Domain}/mfa/associate`,
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${mfaToken}`,
        },
        data: {
          authenticator_types: ["otp"],
        },
      };

      const otpResponse = await axios.request(otpRequest);
      otpResponse.data.token = mfaToken;

      if (otpResponse.status === 200) {
        res.status(200).send(otpResponse?.data);
      }
    }
  } catch (err) {
    console.error(err);

    let {code, message} = err;

    // Status Code for failed Authorization
    if (code === 403) {
      message = "Invalid Password.";
    }

    res.status(code || 500).send({error: message || "Error encountered"});
  }
});

const confirmOTP = onRequest(async (req, res) => {
  const body = req.body;

  try {
    const {mfaToken, userOtpCode} = body;

    const options = {
      method: "POST",
      url: `https://${auth0Domain}/oauth/token`,
      headers: {"content-type": "application/x-www-form-urlencoded"},
      data: new URLSearchParams({
        grant_type: "http://auth0.com/oauth/grant-type/mfa-otp",
        client_id: `${auth0ClientId}`,
        mfa_token: `${mfaToken}`,
        client_secret: `${auth0ClientSecret}`,
        otp: `${userOtpCode}`,
      }),
    };

    const enrollment = await axios.request(options);

    if (enrollment.status === 200) {
      res.sendStatus(200);
    }
  } catch (err) {
    let customError = "";

    const {
      status,
      data: {error_description},
    } = err?.response;

    if (status === 403) {
      customError = "Invalid code.";
    }

    res.status(status).send({error: customError || error_description});
  }
});

const unenrollMFA = onRequest(async (req, res) => {
  const body = req.body;

  try {
    const auth0Token = await getAccessToken();

    const config = {
      method: "delete",
      maxBodyLength: Infinity,
      url: `https://${auth0Domain}/api/v2/users/${body.userId}/authentication-methods/${body.authFactorId}`,
      headers: {
        "Authorization": `Bearer ${auth0Token}`,
      },
    };

    const request = await axios.request(config);
    res.status(200).send(request.data);
  } catch (err) {
    console.error(err);
  }
});

module.exports = {
  updateUser,
  updatePassword,
  authMethods,
  enrollOTP,
  confirmOTP,
  unenrollMFA,
};
