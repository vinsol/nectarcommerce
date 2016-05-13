import BaseCheckoutView from "./base_checkout_view";
import CheckoutView     from "./checkout_view";

export default function getView(actionName) {
  switch(actionName) {
  case "checkout":
    return CheckoutView;
  default:
    return BaseCheckoutView;
  }
}
