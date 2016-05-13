import AjaxSetup from "../lib/ajax_setup";

export default class AdminBaseView {
  mount() {
    AjaxSetup.setup();
  }
  unmount() {

  }
}
