import BaseView          from "./base_view";
import AdminBaseView     from "./admin_base_view";
import ProductView       from "./products";
import AdminCountryView  from "./admin/countries";
import AdminOrderView    from "./admin/orders";
import AdminCartView     from "./admin/cart";
import AdminZoneView     from "./admin/zones";
import AdminCheckoutView from "./admin/checkout";
import CheckoutView      from "./checkout";
import AdminProductView  from "./admin/products";

// add all the views here.
const views = {ProductView,
               AdminCountryView,
               AdminOrderView,
               AdminCartView,
               AdminZoneView,
               AdminCheckoutView,
               CheckoutView,
               AdminProductView};

export default function viewToRender(view) {
  let viewLookUp   = view.split(".");
  const actionName = viewLookUp.pop();
  const viewName   = viewLookUp.join("");
  let actionLookup = views[viewName];

  if (actionLookup) {
    return actionLookup(actionName);
  } else {
    if (viewLookUp[0] == 'Admin') {
      return AdminBaseView;
    } else {
      return BaseView;
    }
  }
}
