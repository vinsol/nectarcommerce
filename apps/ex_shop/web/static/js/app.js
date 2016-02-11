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

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"
import ajax from "web/static/js/lib/ajax_setup";
import zone from "web/static/js/zone";
import state from "web/static/js/state";

ajax.setup();
window.zone = zone;
window.state = state;

// TODO: Re-write in ES6 style
$(document).ready(function() {
  $(document).on("click", "#add_option_value", function(e) {
    e.preventDefault();
    let time = new Date().getTime();
    let template = $(this).data("template");
    var uniq_template = template.replace(/\[0\]/g, `[${time}]`);
    uniq_template = uniq_template.replace(/_0_/g, `_${time}_`);
    $(this).after(uniq_template);
  });

  $(document).on("click", "#delete_option_value", function(e) {
    e.preventDefault();
    $(this).parent().remove();
  });
});
