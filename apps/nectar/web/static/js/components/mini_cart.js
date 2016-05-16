import React from "react";
import { connect } from 'react-redux';
import CartModal from "./cart_modal";

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
    let badgeClasses = "btn-primary";
    if (this.props.cart_notifications.notifications.length > 0) {
      badgeClasses = "shake btn-danger";
    }
    let mini_cart = (
        <div>
        <a type="button"  className={badgeClasses + " btn btn-default btn-sm"} onClick={this.onClick}>
          Cart <span className="badge">{this.props.cart.cart_summary.items_in_cart}</span>
        </a>
        {modal}
        </div>
    );
    return mini_cart;
  }
}

const mapStateToProps = (state) => ( state.mini_cart );

export default connect(mapStateToProps)(MiniCart);
