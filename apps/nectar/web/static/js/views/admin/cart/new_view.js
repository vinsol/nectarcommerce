import CartCreator from "./cart_creator";
import BaseCartView from "./base_cart_view";

export default class NewView extends BaseCartView {
  mount() {
    super.mount();
    CartCreator.init();
  }

}
