import BaseZoneView from "./base_zone_view";
import Zone from "./zone";

export default class ShowView extends BaseZoneView {

  mount() {
    super.mount();
    const zoneId = document.getElementById("zone").getAttribute("data-zone-id");
    Zone.init(parseInt(zoneId, 10));
  }

  unmount() {
    super.unmount();
  }

}
