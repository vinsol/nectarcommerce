import {combineReducers } from 'redux';
import cart from './cart';
import cart_notifications from './cart_notification';

const mini_cart = combineReducers({cart, cart_notifications});
export default combineReducers({
  mini_cart
});
