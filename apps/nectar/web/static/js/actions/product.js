import Constants from '../constants';
import {httpGet} from '../utils';


const Actions = {
  getProductListing: () => {
    return dispatch => {
      dispatch({type: Constants.FETCHING_PRODUCTS});

      httpGet('/products')
        .then((data) => {
          dispatch({
            type: Constants.PRODUCTS_RECEIVED,
            products: data.products
          });
        });
    };
  }
};

export default Actions;
