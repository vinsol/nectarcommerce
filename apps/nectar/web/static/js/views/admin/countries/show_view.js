import BaseCountryView from "./base_country_view";
import State from "./state";

export default class ShowView extends BaseCountryView {
  mount() {
    super.mount();
    const countryId = document.getElementById("country").getAttribute("data-country-id");
    State.init(parseInt(countryId, 10));
  }

  unmount() {
    super.unmount();
  }
}
