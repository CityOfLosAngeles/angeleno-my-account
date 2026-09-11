import { onRequest } from 'firebase-functions/v2/https';
import admin from 'firebase-admin';
import express from 'express';
import jwt from 'jsonwebtoken';
import jwksClient from 'jwks-rsa';
import { setGlobalOptions } from 'firebase-functions/v2';
import { auth0Domain } from './utils/constants.js';
import * as auth0 from './api/auth0.js';

admin.initializeApp();
setGlobalOptions({
  region: 'us-west1'
})

const app = express();
const client = jwksClient({
  jwksUri: `https://${auth0Domain}/.well-known/jwks.json`
});

const verifyToken = (req, res, next) => {
  const token = req.headers['X-ACCESS-TOKEN'] || req.headers['x-access-token'];
  const userId = req.body.userId || req.query.userId;

  if (!token) {
    return res.status(401).send('Unauthorized: No token provided');
  }

  jwt.verify(token, (header, callback) => {
    client.getSigningKey(header.kid, (err, key) => {
      callback(err, key?.publicKey || key?.rsaPublicKey);
    });
  }, (err, decoded) => {
    if (err) {
      console.error('Token verification failed:', err);
      return res.status(401).send('Unauthorized: Invalid token');
    }
    if (decoded.sub !== userId) {
      return res.status(401).send('Unauthorized: User ID does not match token subject');
    }
    next();
  });
};


app.use(verifyToken);
app.use(express.json());

app.get('/auth0/authMethods', auth0.authMethods);
app.post('/auth0/updateUser', auth0.updateUser);
app.post('/auth0/updatePassword', auth0.updatePassword);
app.post('/auth0/enrollMFA', auth0.enrollMFA);
app.post('/auth0/confirmMFA', auth0.confirmMFA);
app.post('/auth0/unenrollMFA', auth0.unenrollMFA);
app.post('/auth0/removeConnection', auth0.removeConnection);
app.post('/auth0/challengeMfa', auth0.challengeMfa);
app.post('/auth0/requestMFAToken', auth0.requestMFAToken);

export const auth0 = onRequest(app);
