import BaseOrderView from "./base_order_view";
import ShowView from "./show_view";

export default function getView(actionName) {
  switch(actionName) {
  case "show":
    return ShowView;
  default:
    return BaseOrderView;
  }
}
