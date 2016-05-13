import React from "react";
import { connect } from 'react-redux';
import CartNotification from "./cart_notification";
import ReactCSSTransitionGroup from "react-addons-transition-group";
import { Modal } from 'react-bootstrap';
import cartNotificationActions from "../actions/cart_notification";

class DissmissableAlert extends React.Component {

  constructor() {
    super();
    this.removeFromNotifications = this.removeFromNotifications.bind(this);
  }

  removeFromNotifications() {
    this.props.clear(this.props.index);
  }

  render() {
    return (<div className="alert alert-danger">
            <a href="#" class="close" title="close" onClick={this.removeFromNotifications}>×</a>
              <span>{this.props.message}</span>
            </div>);
  }
}

class Alerts extends React.Component {
  render() {
    const alerts = this.props.alerts.map( (alert, idx) => <DissmissableAlert message={alert.message} key={idx} index={idx} clear={this.props.clear}/>);
    return (
      <div>
        {alerts}
      </div>
    );
  }
}

class CartModal extends React.Component {
  constructor() {
    super();
    this.clearAlert = this.clearAlert.bind(this);
  }
  clearAlert(index) {
    this.props.dispatch(cartNotificationActions.clearCartNotification(index));
  }
  render() {
    const tableBody = this.props.lineItems.map((lItem, idx) =>  <tr key={idx}>
                                                                  <td><a href={lItem.path}>{lItem.name}</a></td>
                                                                  <td>{lItem.quantity}</td>
                                                                  <td>{lItem.total}</td>
                                                                </tr>
                                                               );

    const tableStyle = {width: "100%"};

    return(
        <Modal show={this.props.show} onHide={this.props.onHide} title="cart" bsStyle="container">
          <div className="cart-contents">
            <h5>Your cart contents</h5>
            <Alerts alerts={this.props.cartNotifications.notifications} clear={this.clearAlert}/>
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
                             cartNotifications={this.props.cart_notifications}
                             lineItems={this.props.cart.cart_summary.line_items}
                             cartLink={this.props.cart.cart_link}
                             show={this.state.showModal}
                             dispatch={this.props.dispatch}/>;
    if (this.props.cart_notifications.notifications.length > 0) {
      return (
        <div>
        <a type="button" className="shake btn btn-default btn-sm btn-danger" onClick={this.onClick}>
          Cart <span className="badge">{this.props.cart.cart_summary.items_in_cart}</span>
        </a>
        {modal}
        </div>
      );
    } else {
      return (
        <div>
        <a type="button" className="btn btn-default btn-sm btn-primary" onClick={this.onClick}>
          Cart <span className="badge">{this.props.cart.cart_summary.items_in_cart}</span>
        </a>
        {modal}
        </div>
      );
    }
  }
}

const mapStateToProps = (state) => ( state.mini_cart );

export default connect(mapStateToProps)(MiniCart);
