import Constants from "../constants";

const initialState = {
  notifications: []
};

export default function reducer(state = initialState, action = {}) {
  switch(action.type) {
  case Constants.CART_NOTIFICATION_RECEIVED:
    return {...state, notifications: [...state.notifications, {message: action.notification_message}]};
  case Constants.CART_NOTIFICATION_CLEARED:
    return {...state, notifications: [...state.notifications.slice(0, action.notification_index), ...state.notifications.slice(action.notification_index+1)]};
  default:
    return state;
  }
}
