import Constants from '../constants';
import {httpGet} from '../utils';


const Actions = {
  fetchCurrentCartSummary: (callback) => {
    return dispatch => {
      dispatch({type: Constants.FETCHING_CART_SUMMARY});

      httpGet('/cart?summary=true')
        .then((data) => {
          dispatch({
            type: Constants.CART_SUMMARY_RECEIVED,
            cart_summary: data
          });
        }).then(function(data) {callback();});
    };
  }
};

export default Actions;
