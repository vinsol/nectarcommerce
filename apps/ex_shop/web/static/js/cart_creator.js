export default {
  ordersList: $("#orders-list"),
  createOrderButton: $("#create-order"),
  init: function() {
    this.bindEvents();
  },

  bindEvents: function() {
    let _this = this;
    $('#user-list').on('change', function() {
      let userId = $(this).val();
      let userName = $(this).find(":selected").text();
      if (userId) {
        _this.fetchUsersPendingOrders(userId);
        _this.updateCreateButton(userId, userName);
      } else {
        _this.updateCreateButton("", "Guest");
      }
    });

      this.createOrderButton.on('click', function(){

      });
  },

  fetchUsersPendingOrders: function(userId) {
    if (!userId) {
      return;
    }
    let _this = this;
    $.ajax({
      url: `/admin/users/${userId}/all_pending_orders`,
      type: "get",
      success: function(data) {
        _this.displayUsersOrderList(data);
      }
    });
  },

  updateCreateButton: function(userId, userName) {
    this.createOrderButton.data('user-id', userId);
      this.createOrderButton.html(`create order for ${userName}`);
  },

  displayUsersOrderList: function(orders) {
    this.ordersList.html("");
    orders.map((order) => {
      this.ordersList.append(this.buildOrderHtml(order));
    });
  },

  buildOrderHtml: function(order) {
    return `order created on ${order.created_on} in ${order.state},
        click <a href="${order.edit_cart_link}">here</a> to continue adding products to cart.
            Or, click <a href="${order.continue_checkout_link}">here</a> to continue checkout`;
  }
};
