import BaseProductView from "./base_product_view";
import EditView        from "./edit_view";

export default function getView(actionName) {
  switch(actionName) {
  case "edit":
    return EditView;
  case "new":
    return EditView;
  default:
    return BaseCartView;
  }
}
