export default {
  lineItems: $("#line_items"),
  error: $("p.alert.alert-danger"),

  init: function(id) {
    this.orderId = id;
    this.bindEvents();
  },

  bindEvents: function() {
    this.bindFullfillmentToggle();
  },

  bindFullfillmentToggle: function() {
    let _this = this;
    this.lineItems.on('change', '.fullfillment', function() {
      let checkbox = $(this);
      let fullfilled = checkbox.checked;
      let lineItemId = checkbox.data('line-item-id');
      _this.updateFullfillment(lineItemId, fullfilled);
    });
  },

  updateFullfillment: function(lineItemId, fullfilled) {
    let _this = this;
    $.ajax({
      url: `/admin/orders/${this.orderId}/line_items/${lineItemId}/update_fullfillment`,
      data: {
        line_item: {
          fullfilled: fullfilled
        }
      },
      contentType: "application/json",
      method: 'put',
      success: function() {
        _this.removeCheckbox(lineItemId);
      },
      error: function(data) {
        _this.displayErrorNotification(data);
        _this.recheckLineItem(lineItemId);
      }
    });
  },

  displayErrorNotification: function(msg) {
    this.error.html(this.toErrorMessage(msg.responseJSON));
  },

  toErrorMessage: function(response) {
    return response.errors.map(({
      detail, field
    }) => `${field}: ${detail}`).join("\n");
  },

  removeCheckbox: function(lineItemId) {
    this.lineItems.find(`.fullfillment[data-line-item-id=${lineItemId}]`).replaceWith("<strong>cancelled</strong>");
  },
  recheckLineItem: function(lineItemId) {
    this.lineItems.find(`.fullfillment[data-line-item-id=${lineItemId}]`)[0].checked = true;
  }
}
