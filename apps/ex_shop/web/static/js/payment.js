export default {
  form: $('#payment-form > form'),

  init: function({
    braintreeClientToken
  }) {
      debugger;
      this.initializeBrainTreeClient(braintreeClientToken);
    this.bindFormSubmissionListner();
  },

  initializeBrainTreeClient: function(clientToken) {
    this.brainTreeClient = new braintree.api.Client({
      clientToken
    });
  },

  bindFormSubmissionListner: function() {
    this.form.submit((event) => {
      if (this.isBrainTreePayment() && !this.noncePresent()) {
        event.preventDefault();
        this.tokenizeCard();
      } else {
        this.form.off('submit').submit();
      }
    });
  },

  tokenizeCard: function() {
    let brainTreeForm = this.form.find('.payment-form[data-for=braintree]');
    let number = brainTreeForm.find('input[name="order[payment_method][card_number]"]').val();
    let expirationDate = brainTreeForm.find('select').map((idx, val) => val.value).toArray().join("/");
    let _this = this;
    this.brainTreeClient.tokenizeCard({
        number, expirationDate
      },
      function(err, nonce) {
        if (err) {
          alert(err);
          return;
        }

        let nonce_input = $("<input>").attr("type", "hidden").attr("name", "order[payment_method][nonce]").val(nonce);
        _this.form.append($(nonce_input));
        _this.form.off('submit').submit();
      });
  },

  isBrainTreePayment: function() {
    let checked = $(this.form.find("input[type=checkbox]").filter((_, checkbox) => checkbox.checked));
    return checked.closest('.payment-form').data('for') == 'braintree';
  },

  noncePresent: function() {
    return !!this.form.find('input[name="order[payment_method][nonce]"]').val();
  }
};
