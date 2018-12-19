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
import "phoenix_html"

window.onmount = require('onmount')
window._ = require('lodash')
window.moment = require('moment')
window.Inputmask = require('inputmask');

glob('./behaviors/*', (e, files) => { files.forEach(require) })

$(function () { onmount() })

alertify.defaults = {
  // notifier defaults
  notifier:{
    // auto-dismiss wait time (in seconds)
    delay:5,
    // default position
    position:'top-right',
    // adds a close button to notifier messages
    closeButton: false
  }
}

onmount('div[role="request_consult"]', function(){
  $('.ui.dropdown').dropdown({ fullTextSearch: "exact" });
});
// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"
