export default {
  addButton: $("#add"),
  selection: $("#zoneable-select"),
  zoneableList: $("#zoneable-list"),

  init: function(zoneId) {
      this.bindEvents();
      this.zoneId = zoneId;
  },

  bindEvents: function() {
    this.addButton.on('click', () => {
      let zoneable_id = this.selection.val();
      this.addNewZoneMember(zoneable_id);
    });
    let _this = this;
    this.zoneableList.on('click', '.delete', function() {
      let zoneable_id = $(this).parent().data("zoneable-id");
      _this.deleteZoneMember(zoneable_id);
    });
  },

  addNewZoneMember: function(zoneable_id) {
    let data = {
      zone_member: {
        zoneable_id: zoneable_id
      }
    };
    let _this = this;
    $.ajax({
      url: `/admin/zones/${_this.zoneId}/members`,
      type: "post",
      dataType: "json",
      data: data,
      success: function(data) {
        _this.addToZoneableList(data);
        _this.removeFromZoneableOption(zoneable_id);
      }
    });
  },

  deleteZoneMember: function(zoneable_id) {
    let _this = this;
    $.ajax({
      url: `/admin/zones/${_this.zoneId}/members/${zoneable_id}`,
      type: "delete",
      success: function(data) {
        _this.removeFromZoneableList(zoneable_id);
        _this.addToZoneableOption(data);
      }
    });
  },

  removeFromZoneableOption: function(zoneable_id) {
    $(`option[value=${zoneable_id}]`).remove();
  },

  addToZoneableOption: function(zoneable) {
    let zoneable_html = `<option value=${zoneable["id"]}>${zoneable["name"]}</option>`;
    this.selection.append(zoneable_html);
  },

  addToZoneableList: function(zoneable) {
    let html = `<li data-zoneable-id=${zoneable["id"]}>${zoneable["name"]}<button class="delete btn btn-danger btn-small">X</button></li>`;
    this.zoneableList.append(html);
  },

  removeFromZoneableList: function(zoneable_id) {
    this.zoneableList.find(`[data-zoneable-id=${zoneable_id}]`).remove();
  }

};
