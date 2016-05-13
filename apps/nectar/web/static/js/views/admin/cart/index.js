import BaseCartView from "./base_cart_view";
import EditView     from "./edit_view";
import NewView      from "./new_view";

export default function getView(actionName) {
  switch(actionName) {
  case "edit":
    return EditView;
  case "new":
    return NewView;
  default:
    return BaseCartView;
  }
}
