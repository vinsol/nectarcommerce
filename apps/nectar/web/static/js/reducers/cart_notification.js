import Constants from "../constants";

const initialState = {
  notification_message: ""
};

export default function reducer(state = initialState, action = {}) {
  switch(action.type) {
  case Constants.CART_NOTIFICATION_RECEIVED:
    return {...state, notification_message: action.notification_message};
  case Constants.CART_NOTIFICATION_CLEARED:
    return {...state, notification_message: ""};
  default:
    return state;
  }
}
