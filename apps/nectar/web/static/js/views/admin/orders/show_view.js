import OrderShow from "./order_show";
import BaseOrderView from "./base_order_view";


export default class ShowView extends BaseOrderView {
  mount() {
    super.mount();
    const orderId = document.getElementById("order").getAttribute("data-order-id");
    OrderShow.init(parseInt(orderId, 10));
  }

  unmount() {
    super.unmount();
  }
}
