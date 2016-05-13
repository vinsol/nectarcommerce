import cartNotificationActions from "../actions/cart_notification";


export default class CartNotificationListener {
  constructor(socket, store, options) {
    this.store   = store;
    this.socket  = socket;
    this.channel = socket.channel("cart:"+options["cart_id"], {});
    this.channel.join();
    this.channel.on("new_notification", this.dispatchCartNotification.bind(this));
  }

  dispatchCartNotification({msg}) {
    this.store.dispatch(cartNotificationActions.sendCartNotification(msg));
  }
}
