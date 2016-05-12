export default {
  productList: $("#product-listing"),
  cart: $("#cart"),
  error: $("p.alert.alert-danger"),

  init: function(id) {
    this.orderId = id;
    this.bindEvents();
  },

  bindEvents: function() {
    this.bindAddToCart();
    this.bindRemoveFromCart();
    this.bindUpdateInCartQuantity();
  },

  bindAddToCart: function() {
    let _this = this;
    this.productList.on('click', '.add-to-cart', function() {
      let product = $(this).closest('.product');
      let variantId = product.find('[name=variant]').val() ;
      let quantity = product.find('input[name=quantity]').val();
      _this.addToCart(variantId, quantity);
    });
  },

  bindRemoveFromCart: function() {
    let _this = this;
    this.cart.on('click', '.remove-from-cart', function() {
      let lineItem = $(this).closest('.line-item');
      let lineItemId = lineItem.data('line-item-id');
      _this.removeFromCart(lineItemId);
    });
  },

  bindUpdateInCartQuantity: function() {
    let _this = this;
    this.cart.on('click', '.update-cart-quantity', function() {
      let lineItem = $(this).closest('.line-item');
      let lineItemId = lineItem.data('line-item-id');
      let updatedQuantity = lineItem.find('input').val();
      _this.updateLineItem(lineItemId, updatedQuantity);
    });
  },

  addToCart: function(variantId, quantity = 0) {
    let _this = this;
    $.ajax({
      url: `/admin/orders/${this.orderId}/line_items`,
      method: 'post',
      data: {
        line_item: {
          variant_id: variantId,
          quantity: quantity
        }
      },
      beforeSend: function() {
        _this.clearErrorMessage();
      },
      success: function(lineItem) {
        _this.appendOrUpdateInCart(lineItem);
      },
      error: function(data) {
        _this.setErrorMessage(data);
      }
    });
  },

  updateLineItem: function(lineItemId, quantity = 0) {
    let _this = this;
    $.ajax({
      url: `/orders/${this.orderId}/line_items/${lineItemId}`,
      data: {
        quantity: quantity
      },
      method: 'put',
      beforeSend: function() {
        _this.clearErrorMessage();
      },
      success: function(lineItem) {
        _this.appendOrUpdateInCart(lineItem);
      },
      error: function(data) {
        _this.setErrorMessage(data);
      }
    });
  },

  removeFromCart: function(lineItemId) {
    let _this = this;
    $.ajax({
      url: `/admin/orders/${this.orderId}/line_items/${lineItemId}`,
      method: 'delete',
      beforeSend: function() {
        _this.clearErrorMessage();
      },
      success: function(lineItem) {
        _this.removeFromCartListing(lineItemId);
      },
      error: function(data) {
        _this.setErrorMessage(data);
      }
    });
  },

  removeFromCartListing: function(lineItemId) {
    this.cart.find(`li.line-item[data-line-item-id=${lineItemId}]`).remove();
  },

  appendOrUpdateInCart: function(lineItem) {
    let existingLineItem = this.cart.find(`li.line-item[data-line-item-id=${lineItem.id}]`);
    if (existingLineItem.length > 0) {
      if (lineItem.quantity) {
        existingLineItem.replaceWith(this.makeLineItemHtml(lineItem));
      } else {
        existingLineItem.html("");
      }
    } else {
      this.cart.append(this.makeLineItemHtml(lineItem));
    }
  },

  makeLineItemHtml: function(lineItem) {
    return `
            <li class="list-group-item line-item row" data-line-item-id="${lineItem.id}">
            <span class="col-lg-6">${lineItem.variant.display_name} X ${lineItem.quantity}</span>
            <span class="col-lg-6">
            <button class="btn btn-danger btn-sm remove-from-cart pull-right">-</button>
            </span>
            </li>
        `;
  },

  setErrorMessage: function(msg) {
    this.error.html(this.toErrorMessage(msg.responseJSON));
  },

  clearErrorMessage: function() {
    this.error.html("");
  },

  toErrorMessage: function(response) {
    return response.errors.map(({
      detail, field
    }) => `${field}: ${detail}`).join("\n");
  }
};
