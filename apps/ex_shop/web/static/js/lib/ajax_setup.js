let csrf_token = document.querySelector('meta[name=csrf]').content;
export default {
    csrf_token,
    setup() {
        $.ajaxSetup({headers: {"X-CSRF-TOKEN": this.csrf_token}});
    }
};
