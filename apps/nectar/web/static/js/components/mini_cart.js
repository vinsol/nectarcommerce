import React from "react";
import { connect } from 'react-redux';
import CartNotification from "./cart_notification";
import ReactCSSTransitionGroup from "react-addons-transition-group";
import { Modal } from 'react-bootstrap';


class CartModal extends React.Component {
  render() {
    const tableBody = this.props.lineItems.map((lItem, idx) =>  <tr key={idx}>
                                                                  <td>{lItem.name}</td>
                                                                  <td>{lItem.quantity}</td>
                                                                  <td>{lItem.total}</td>
                                                                </tr>
                                                               );

    const tableStyle = {width: "100%"};
    return(
        <Modal show={this.props.show} onHide={this.props.onHide} title="cart" bsStyle="container">
          <div className="cart-contents">
            <h5>Your cart contents</h5>
            <div className="alert alert-danger">{this.props.cartNotification.notification_message}</div>
            <table className="table table-responsive" style={tableStyle}>
              <thead>
                <tr><th>Product</th><th>Quantity</th><th>Cost</th></tr>
              </thead>
              <tbody>
                {tableBody}
              </tbody>
            </table>
            <a href={this.props.cartLink}>Go To My Cart</a>
          </div>
        </Modal>
    );
  }
}

class MiniCart extends React.Component {
  constructor() {
    super();
    this.state = {showModal: false};
    this.onClick = this.onClick.bind(this);
    this.onHide = this.onHide.bind(this);
  }

  onClick() {
    this.setState({showModal: true});
  }

  onHide() {
    this.setState({showModal: false});
  }

  render() {
    var cart_link = "" + this.props.cart.cart_link;
    const modal = <CartModal onHide={this.onHide}
                             cartNotification={this.props.cart_notification}
                             lineItems={this.props.cart.cart_summary.line_items}
                             cartLink={this.props.cart.cart_link}
                             show={this.state.showModal}/>;
    if (this.props.cart_notification.notification_message) {
      return (
        <div>
        <a type="button" className="shake btn btn-default btn-sm btn-danger" onClick={this.onClick}>
          <span className=""></span> {this.cartMessage()}
        </a>
        {modal}
        </div>
      );
    } else {
      return (
        <div>
        <a type="button" className="btn btn-default btn-sm btn-primary" onClick={this.onClick}>
          <span className=""></span> {this.cartMessage()}
        </a>
        {modal}
        </div>
      );
    }
  }

  cartMessage() {
    const itemsInCart = this.props.cart.cart_summary.items_in_cart;
    if (itemsInCart == 0) {
      return "Cart Empty";
    } else if (itemsInCart == 1) {
      return `${itemsInCart} item in cart`;
    } else {
      return `${itemsInCart} items in cart`;
    }
  }

}

const mapStateToProps = (state) => ( state.mini_cart );

export default connect(mapStateToProps)(MiniCart);
