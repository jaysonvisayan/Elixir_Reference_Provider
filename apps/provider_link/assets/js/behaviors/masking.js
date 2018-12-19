onmount('input[role="mask"]', function () {
  var Inputmask = require('inputmask');

  var mobile_mask = new Inputmask("0\\999-999-99-99");
  var date_mask = new Inputmask("99/99/9999");
  var phone_mask = new Inputmask("999-99-99");
  var time_mask = new Inputmask("99:99");
  var pin_mask = new Inputmask("999999");
  var card_mask = new Inputmask("9999-9999-9999-9999");

  pin_mask.mask($('.pin_mask'));
  time_mask.mask($('.time_mask'));
  phone_mask.mask($('.phone_mask'));
  date_mask.mask($('.date_mask'));
  mobile_mask.mask($('.mobile_mask'));
  card_mask.mask($('.card_mask'));
})
