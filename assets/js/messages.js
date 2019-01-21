import $ from 'jquery';

$(document).ready(function () {
    let delete_button = $("button.delete");
    let message = delete_button.parent();
    delete_button.click(function () {
        message.remove();
    });
});