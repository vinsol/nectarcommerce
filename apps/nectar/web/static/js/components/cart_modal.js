import { Modal } from "react-bootstrap";
import React from "react";
import StackedAlerts from "./stacked_alerts";
import cartNotificationActions from "../actions/cart_notification";


export default class CartModal extends React.Component {
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
            <StackedAlerts alerts={this.props.cartNotifications.notifications} clear={this.clearAlert}/>
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
