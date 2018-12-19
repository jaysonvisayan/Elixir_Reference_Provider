onmount('div[role="forgot_password"]', function() {

  function showChannel() {
    if ($('input[name="session[channel]"]:checked').val() == "Email") {
      $('div[name="input[email]"]').show();
      $('div[name="input[mobile]"]').hide();
    } else {
      $('div[name="input[email]"]').hide();
      $('div[name="input[mobile]"]').show();
    }
  }

  showChannel();

  $('input[name="session[channel]"]').on('change', function(){
    showChannel();
    $('div[id="message"]').hide();
    $('input[name="session[email]"]').val('');
    $('input[name="session[mobile]"]').val('');
  });
});
