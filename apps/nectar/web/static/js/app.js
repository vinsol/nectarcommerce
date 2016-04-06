// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html";
import ajax from "./lib/ajax_setup";
import zone from "./zone";
import state from "./state";
import order from "./order";
import order_show from "./order_show";
import payment from "./payment";
import cart_creator from "./cart_creator";

let nectar = {};
nectar.ajax_setup = ajax.setup;
nectar.zone = zone;
nectar.state = state;
nectar.order = order;
nectar.payment = payment;
nectar.order_show = order_show;
nectar.cart_creator = cart_creator;
// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"

// TODO: Re-write in ES6 style
$(document).ready(function() {
  $(document).on("click", "#add_option_value, #add_product_option_type, #add_category, #add_product_category", function(e) {
    e.preventDefault();
    let time = new Date().getTime();
    let template = $(this).data("template");
    var uniq_template = template.replace(/\[0\]/g, `[${time}]`);
    uniq_template = uniq_template.replace(/_0_/g, `_${time}_`);
    $(this).after(uniq_template);
  });

  $(document).on("click", "#delete_option_value, #delete_product_option_type, #delete_category, #delete_product_category", function(e) {
    e.preventDefault();
    $(this).parent().remove();
  });
});

nectar.setup = function() {
  for (var prop in this) {
        window[prop] = nectar[prop];
  }
  ajax_setup();
};

nectar.setup();

export default nectar;
