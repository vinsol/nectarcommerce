export default {
  ordersList: $("#orders-list"),
  createOrderButton: $("#create-order"),
  userIdInput: $("#order_user_id"),

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
        _this.userIdInput.attr("value", "");
          _this.ordersList.html("");
      }
    });

    this.createOrderButton.on('click', function() {

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
    this.userIdInput.attr('value', userId);
    this.createOrderButton.html(`create order for ${userName}`);
  },

  displayUsersOrderList: function(orders) {
    this.ordersList.html("");
    orders.map((order) => {
      this.ordersList.append(this.buildOrderHtml(order));
    });
  },

  buildOrderHtml: function(order) {
      return `<li>order created on ${order.created_on} in state: <strong>${order.state}</strong>,
        click <a href="${order.edit_cart_link}" class="btn btn-danger">here</a> to continue adding products to cart.
            Or, click <a href="${order.continue_checkout_link}" class="btn btn-primary">here</a> to continue checkout</li>`;
  }
};
