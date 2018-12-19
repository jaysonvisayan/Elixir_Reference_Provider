onmount('#change_password', function(){
  $('#change_password').form({
    inline: true,
    on: 'blur',
    fields: {
      'user[current_password]': {
        identifier: 'user[current_password]',
        rules: [{
          type  : 'empty',
          prompt: 'Please enter current password'
        }]
      },
      'user[password]': {
        identifier: 'user[password]',
        rules: [{
          type  : 'empty',
          prompt: 'Please enter password'
        }]
      },
      'user[password_confirmation]': {
        identifier: 'user[password_confirmation]',
        rules: [{
          type  : 'empty',
          prompt: 'Please enter password confirmation'
        }]
      }
    }
  })
});

onmount('#mobile_verification', function(){
  if (!sessionStorage.clickcount)
  {
     $('#resend').hide();
  }
  var counter = 10;
  var id = setInterval(function() {
     counter--;

     if (counter === 0) 
     {
        if (sessionStorage.clickcount) { 
        } else {
            sessionStorage.clickcount = 1;
            $('#resend').show();
        }
     } 
  }, 1000);
});

onmount('#forgot_password', function(){
  sessionStorage.clear();
  sessionStorage.removeItem("clickcount");
});