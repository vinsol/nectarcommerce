import Constants from "../constants";

const Actions = {
  sendCartNotification: (msg) => {
    return dispatch => {
      dispatch({type: Constants.CART_NOTIFICATION_RECEIVED,
                notification_message: msg});
    };
  },

  clearCartNotification: () => {
    return dispatch => {
      dispatch({type: Constants.CART_NOTIFICATION_CLEARED});
    };
  }

};

export default Actions;
