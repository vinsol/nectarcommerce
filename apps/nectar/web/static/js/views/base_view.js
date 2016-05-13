import ReactDOM       from "react-dom";
import React          from "react";
import { Provider }   from "react-redux";
import socket from "../socket";
import { MiniCart, CartNotification }   from "../components";
import configureStore from "../store";
import cartActions    from "../actions/cart";
import CartNotificationListener from "../listeners/cart_notification_listener";


export default class BaseView {
  mount() {
    this.store = configureStore();
    ReactDOM.render(<Provider store={this.store}>
                      <div>
                        <MiniCart/>
                      </div>
                    </Provider>,
                    document.getElementById('cart'));

    this.store.dispatch(cartActions.fetchCurrentCartSummary(this.setupListeners.bind(this)));
  }

  unmount() {
  }

  setupListeners() {
    this.socket = socket;
    socket.connect();
    new CartNotificationListener(socket, this.store, {cart_id: this.store.getState().mini_cart.cart.cart_summary.id});
  }
}
