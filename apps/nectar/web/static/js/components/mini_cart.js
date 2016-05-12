import React from "react";
import { connect } from 'react-redux';

class CartSummary extends React.Component {
  render() {
    return (<div className="cart">{this.cartMessage()}</div>);
  }

  cartMessage() {
    if (this.props.items_in_cart == 0) {
      return "Cart Empty";
    } else if (this.props.items_in_cart == 1) {
      return `${this.props.items_in_cart} item in cart`;
    } else {
      return `${this.props.items_in_cart} items in cart`;
    }
  }
}

CartSummary.propTypes = {
  items_in_cart: function(props, propName, componentName) {
    if (props[propName] < 0) {
      return new Error(`Invalid prop ${propName} supplied to ${componentName}, should be >= 0`);
    }
    return null;
  }
};

class MiniCart extends React.Component {
  render() {
    return (<div className="btn btn-primary">
            <CartSummary items_in_cart={this.props.cart_summary.items_in_cart}/>
            </div>);
  }
}

const mapStateToProps = (state) => ( state.mini_cart );

export default connect(mapStateToProps)(MiniCart);
