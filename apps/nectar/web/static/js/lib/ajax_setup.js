export default {
  setup() {
    let csrf_token = document.querySelector('meta[name=csrf]').content;
    $.ajaxSetup({
      headers: {
        "X-CSRF-TOKEN": csrf_token
      }
    });
  }
};
