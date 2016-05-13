import IndexView from "./index_view";
import BaseProductView from "./base_product_view";

export default function getView(actionName) {
  switch(actionName) {
  case "index":
    return IndexView;
  default:
    return BaseProductView;
  }
};
