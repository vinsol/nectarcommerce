import {combineReducers } from 'redux';
import cart from './cart';
import cart_notification from './cart_notification';

const mini_cart = combineReducers({cart, cart_notification});
export default combineReducers({
  mini_cart
});
