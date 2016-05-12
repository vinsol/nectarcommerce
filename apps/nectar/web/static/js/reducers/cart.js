import Constants from '../constants';

const initialState = {
  cart_summary: {items_in_cart: 0, id: -1},
  fetching: true
};

export default function reducer(state = initialState, action = {}) {
  switch(action.type) {
  case Constants.FETCHING_CART_SUMMARY:
    return {...state, fetching: true};
  case Constants.CART_SUMMARY_RECEIVED:
    return {...state, cart_summary: action.cart_summary, fetching: false};
  default:
    return state;
  }
}
