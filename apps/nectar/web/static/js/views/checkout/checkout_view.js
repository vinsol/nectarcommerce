import BaseCheckoutView from "./base_checkout_view";
import Payment from "./payment";

export default class CheckoutView extends BaseCheckoutView {
  mount() {
    super.mount();
    const state = document.getElementById('order').getAttribute('data-order-state');
    if (this[state]) { this[state](); }
  }

  tax() {
    let braintreeForm = document.getElementById('braintree');
    if (braintreeForm) {
      const braintreeClientToken = braintreeForm.getAttribute('data-client-token');
      Payment.init({braintreeClientToken});
    }
  }
}
