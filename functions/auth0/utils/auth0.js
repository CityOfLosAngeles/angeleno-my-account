const jwt = require('jsonwebtoken');
const axios = require('axios');

const {
  auth0Domain,
  auth0ClientId,
  auth0ClientSecret
} = require('./constants.js');

let auth0Token;

const getAccessToken = async () => {
  if (auth0Token) {
    const decodedToken = await jwt.decode(auth0Token);
    const tokenExpiration = decodedToken.exp * 1000;
    const now = Date.now();
    const tokenValid = tokenExpiration > now;
    if (tokenValid) {
      return auth0Token;
    }
  }

  const options = {
    'Content-Type': 'application/x-www-form-urlencoded'
  };

  const body = {
    'grant_type': 'client_credentials',
    'client_id': auth0ClientId,
    'client_secret': auth0ClientSecret,
    'audience': `https://${auth0Domain}/api/v2/`
  };

  try {
    const request = await axios.post(
      `https://${auth0Domain}/oauth/token`,
      body, {
        headers: options
      }
    );

    auth0Token = request.data.access_token;
    return auth0Token;
  } catch (err) {
    console.error(err);
    throw new Error('Error getting access token');
  }
};

const authorizeUser = async (email, password, audience = '/api/v2/') => {
  try {
    const passwordValidationRequest = {
      method: 'POST',
      url: `https://${auth0Domain}/oauth/token`,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      data: new URLSearchParams({
        'grant_type': 'password',
        'username': email,
        'password': password,
        'client_id': auth0ClientId,
        'client_secret': auth0ClientSecret,
        'audience': `https://${auth0Domain}${audience}`,
        'scope': audience === '/api/v2/' ? 'openid' : ''
      })
    };

    return await axios.request(passwordValidationRequest);
  } catch (err) {
    console.error(err);
    throw err;
  }
};

module.exports = {
  getAccessToken,
  authorizeUser
};
