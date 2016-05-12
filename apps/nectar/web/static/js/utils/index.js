import fetch from 'isomorphic-fetch';
import { polyfill } from 'es6-promise';


const defaultHeaders = {
  Accept: 'application/json',
  'Content-Type': 'application/json'
};

function buildHeaders() {
  // fetch csrf token
  const csrfToken = 'dsahdjkashdksahdj'  ;
  return {...defaultHeaders, 'X-CSRF-TOKEN': csrfToken};
}

export function checkStatus(response) {
  if (response.status >= 200 && response.status < 300) {
    return response;
  } else {
    var error = new Error(response.statusText);
    error.response = response;
    throw error;
  }
}

export function parseJSON(response) {
  return response.json();
}

export function httpGet(url) {
  return fetch(url, {headers: buildHeaders(), credentials: 'same-origin'})
         .then(checkStatus).then(parseJSON);
}
