import React from "react";
import { connect } from "react-redux";

class CartNotification extends React.Component {
  render() {
    const cartNotifyMessage = this.props.notification_message;
    if (cartNotifyMessage && cartNotifyMessage != "") {
      return (<div className="cart_notification active alert">{cartNotifyMessage}</div>);
    } else {
      // return inactive cart notification if no message present
      return (<div className="cart_notification inactive"></div>);
    }
  }
}

const mapStateToProps = (state) => (state.cart_notification);

export default connect(mapStateToProps)(CartNotification);
