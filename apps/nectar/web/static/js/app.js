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


// based on: https://blog.diacode.com/page-specific-javascript-in-phoenix-framework-pt-1

import viewToRender from "./views";

class Application {
  constructor() {
    const body = document.getElementsByTagName('body')[0];
    const viewName = body.getAttribute('data-js-view-name');
    const viewClass = viewToRender(viewName);

    this.view = new viewClass();
    window.addEventListener('DOMContentLoaded',
                            this.handleDOMContentLoaded.bind(this),
                            false);
    window.addEventListener('unload',
                            this.handleDocumentUnload.bind(this),
                            false);
  }

  handleDOMContentLoaded() {
    this.view.mount();
  }

  handleDocumentUnload() {
    this.view.unmount();
  }
}

new Application();
