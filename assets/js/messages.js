$('.message .close')
  .on('click', function () {
    $(this)
      .closest('.message')
      .transition('fade')
      ;
  });
;

setTimeout(function () {
  $('.message').transition('fade down');
}, 3000)
