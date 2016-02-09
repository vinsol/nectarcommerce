export default {
  addButton: $("#add"),
  stateList: $("#state-list"),
  stateForm: $("#state-form"),

  init: function(countryId) {
    this.countryId = countryId;
    this.bindEvents();
  },

  bindEvents: function() {
    this.addButton.on('click', () => {
      this.addNewState();
    });
    let _this = this;
      this.stateList.on('click', '.delete', function() {
          debugger;
      let state_id = $(this).closest('tr').data("state-id");
      _this.deleteState(state_id);
    });
  },

  addNewState: function() {
    let data = {
      state: {
        name: this.stateForm.find("input[name=name]").val(),
        abbr: this.stateForm.find("input[name=abbr]").val()
      }
    };
    let _this = this;
    $.ajax({
      url: `/admin/countries/${_this.countryId}/states`,
      type: "post",
      dataType: "json",
        data: data,
        beforeSend: function() {
            debugger;
            _this.clearErrors();
        },
      success: function(data) {
        _this.addToStateList(data);
      },
        error: function(data) {
            _this.renderErrors(data);
        }
    });
  },

    renderErrors: function(data)   {
        let errors = data.responseJSON.errors;
        errors.forEach( ({detail, field}) => {
            this.stateForm
                .find(`input[name=${field}]`)
                .after(`<span class='danger error'>${detail}</span>`);
        });
    },
    clearErrors: function() {
        this.stateForm.find('.error').remove();
    },

  deleteState: function(state_id) {
      let _this = this;
      debugger;
    $.ajax({
      url: `/admin/countries/${_this.countryId}/states/${state_id}`,
      type: "delete",
      success: function(data) {
        _this.removeFromStateList(state_id);
      }
    });
  },

  addToStateList: function(state) {
    let html =
      `<tr data-state-id=${state["id"]}>
          <td>${state["name"]}</td>
          <td>${state["abbr"]}</td>
          <td><button class="delete btn btn-danger">X</button></td>
          </tr>`;
    this.stateList.append(html);
  },

  removeFromStateList: function(state_id) {
    this.stateList.find(`[data-state-id=${state_id}]`).remove();
  }

};
