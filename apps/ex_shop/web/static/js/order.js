export default {
    productList: $("#product-listing"),
    cart: $("#cart"),
    error: $("p.alert.alert-danger"),

    init: function(id) {
        console.log(`Adding products to order ${id}`);
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
            let productId = product.data('product-id');
            let quantity = product.find('input').val();
            _this.addToCart(productId, quantity);
        });
    },

    bindRemoveFromCart: function() {
        let _this = this;
        this.cart.on('click', '.remove-from-cart', function() {
            let lineItem = $(this).closeset('.line-item');
            let lineItemId = lineItem.data('lineitem-id');
            _this.updateLineItem(lineItemId);
        });
    },

    bindUpdateInCartQuantity: function() {
        let _this = this;
        this.cart.on('click', '.remove-from-cart', function() {
            let lineItem = $(this).closeset('.line-item');
            let lineItemId = lineItem.data('lineitem-id');
            let updatedQuantity = lineItem.find('input').val();
            _this.updateLineItem(lineItemId, updatedQuantity);
        });
    },

    addToCart: function(productId, quantity=0) {
        let _this = this;
        $.ajax({
            url: `/orders/${this.orderId}/lineItems`,
            method: 'post',
            data: {product_id: productId, quantity: quantity},
            beforeSend: function()  { _this.clearErrorMessage(); },
            success: function(lineItem) { _this.appendOrUpdateInCart(lineItem); },
            failure: function(data) { _this.setErrorMessage(data); }
        });
    },

    updateLineItem: function(lineItemId, quantity=0) {
        let _this = this;
        $.ajax({
            url: `/orders/${this.orderId}/lineItems/${lineItemId}`,
            data: { quantity: quantity},
            method: 'put',
            beforeSend: function() { _this.clearErrorMessage(); },
            success: function(lineItem) { _this.appendOrUpdateInCart(lineItem); },
            failure: function(data) { _this.setErrorMessage(data); }
        });
    },

    appendOrUpdateInCart: function(lineItem) {
        let existingLineItem = this.cart.find(`li.line-item[data-lineitem-id=${lineItem.id}]`);
        if (existingLineItem.length > 0) {
            if (lineItem.quantity) {
                existingLineItem.html(this.makeLineItemHtml(lineItem));
            } else {
                existingLineItem.html("");
            }
        } else {
            this.cart.append(this.makeLineItemHtml(lineItem));
        }
    },

    makeLineItemHtml: function(lineItem) {
        return `
            <li class="list-group-item line-item" data-lineitem-id="${lineItem.id}">
            ${lineItem.product.name}
            <span class="pull-right">
            <input name="" type="text" value="${lineItem.quantity}"/>
            <button class="btn btn-primary">update</button>
            <button class="btn btn-danger remove-from-cart">-</button>
            </span>
            </li>
        `;
    },

    setErrorMessage: function(msg) {
        this.error.append(msg);
    },

    clearErrorMessage: function() {
        this.error.innerHTMl("");
    }
};
