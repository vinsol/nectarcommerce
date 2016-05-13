import Constants from "../constants";

const Actions = {
  sendCartNotification: (msg) => {
    return dispatch => {
      dispatch({type: Constants.CART_NOTIFICATION_RECEIVED,
                notification_message: msg});
    };
  },

  clearCartNotification: (index) => {
    return dispatch => {
      dispatch({type: Constants.CART_NOTIFICATION_CLEARED, notification_index: index});
    };
  }

};

export default Actions;
