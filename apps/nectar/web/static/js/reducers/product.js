import Constants from '../constants';

// future enhancement, add pagination
const initialState = {
  products: [],
  fetching: true,
  category_filters: []
};

export default function reducer(state = initialState, action={}) {
  switch(action.type) {
  case Constants.FETCHING_PRODUCTS:
    return {...state, fetching: true};
  case Constants.PRODUCTS_RECEIVED:
    return {...state, fetching: false, products: action.products };
  default:
    return state;
  }
}
