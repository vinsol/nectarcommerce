import {combineReducers } from 'redux';
import cart from './cart';
import cart_notification from './cart_notification';
import product from './product';

export default combineReducers({
  mini_cart: cart,
  products: product,
  cart_notification: cart_notification
});
