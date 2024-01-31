const axios = require("axios");
const {
  auth0Domain,
  auth0ClientId,
  auth0ClientSecret
} = require("./constants.js");

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

const authorizeUser = async (email, password, audience = "/api/v2/") => {
  try {
    const passwordValidationRequest = {
      method: "POST",
      url: `https://${auth0Domain}/oauth/token`,
      headers: {
        "Content-Type": "application/x-www-form-urlencoded"
      },
      data: new URLSearchParams({
        "grant_type": "password",
        "username": email,
        "password": password,
        "client_id": auth0ClientId,
        "client_secret": auth0ClientSecret,
        "audience": `https://${auth0Domain}${audience}`,
        "scope": audience === "/api/v2/" ? "openid" : ""
      })
    };

    return await axios.request(passwordValidationRequest);
  } catch (err) {
    const {
      status,
      data: {
        error_description,
      }
    } = err?.response;

    const error = new Error(error_description || "Auth0 Authorization Failed");
    error.code = status || 500;

    throw error;
  }
};

module.exports = {
  getAccessToken,
  authorizeUser
};
