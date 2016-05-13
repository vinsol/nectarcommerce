import BaseCartView from "./base_cart_view";
import Order from "./order";

export default class EditView extends BaseCartView {
  mount() {
    super.mount();
    const orderId = document.getElementById("order").getAttribute("data-order-id");
    Order.init(parseInt(orderId, 10));
  }

  unmount() {
    super.unmount();
  }
}
