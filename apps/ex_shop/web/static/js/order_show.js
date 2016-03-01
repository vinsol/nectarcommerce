export default {
  lineItems: $("#line_items"),
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
    $.ajax({
      url: `/admin/orders/${this.orderId}/line_items/${lineItemId}/update_fullfillment`,
      data: {
        line_item: {
          fullfilled: fullfilled
        }
      },
      contentType: "application/json",
      method: 'put'
    });
  }

}
