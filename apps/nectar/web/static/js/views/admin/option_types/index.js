import BaseOptionTypeView from "./base_option_type_view";
import EditView        from "./edit_view";

export default function getView(actionName) {
  switch(actionName) {
  case "edit":
    return EditView;
  case "new":
    return EditView;
  default:
    return BaseOptionTypeView;
  }
}
