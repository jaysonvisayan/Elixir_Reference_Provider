onmount('div[id="show_otp"]', function(){

  $('#verify').on('click', function(){
    let coverage = $('input[id="coverage"]').val();

    if (coverage == 'op consult') {
      $('div[id="modal_options"]')
      .modal({closable: false,
             autofocus: false,
             observeChanges: true})
             .modal('show');
    }
  });

  /*SWIPE CARD CHOOSE OPTION*/
  $('#choose_option_swipe_card').on('click', function() {
    $('input[name="cardno1"]').val('');
    $('input[name="cardno2"]').val('');
    $('input[name="cardno3"]').val('');
    $('input[name="cardno4"]').val('');
    $('#card').val('');
    $('div[id="message"]').remove();

    $('div[id="modal_option_swipe_card"]')
    .modal({closable: false,
           autofocus: false,
           observeChanges: true})
           .modal('show');
  })

  /*SWIPE CARD RETURN CHOOSE OPTION*/

  $('#choose_other_options_swipe_card').on('click', function() {
    $('div[id="modal_options"]')
    .modal({closable: false,
           autofocus: false,
           observeChanges: true})
           .modal('show');
  })

  /*SWIPE CARD AUTHENTICATE*/
  $('button[id="verify_loa_swipe_card"]').on('click', function(){
    let cardno1 = $('input[name="cardno1"]').val()
    let cardno2 = $('input[name="cardno2"]').val()
    let cardno3 = $('input[name="cardno3"]').val()
    let cardno4 = $('input[name="cardno4"]').val()
    $('#card').val(cardno1 + cardno2 + cardno3 + cardno4)

    let card = $('#card').val();
    let loa_id = $('input[id="loa_id"]').val();

    if (card.length == '16') {
      $.ajax({
        url: `/loas/${loa_id}/verify/swipe_card/${card}`,
        type: 'get',
        success: function(response) {
          console.log(response)

          if (response.valid == true) {
              alertify.success('<i class="close icon"></i><p>' + response.message + '</p>', 0);
            setTimeout(function() {
              document.location.href="/";
            }, 1000);
          } else {
            $('div[id="message"]').remove();
            $('p[role="append"]').append('<div id="message" class="ui negative message">' + response.message + '</div>')
          }
        }
      });
    }
    else if (card.length == '0') {
      $('div[id="message"]').remove()
      $('p[role="append"]').append('<div id="message" class="ui negative message">Card No is required.</div>')
    }
    else {
      $('div[id="message"]').remove()
      $('p[role="append"]').append('<div id="message" class="ui negative message">Card No should be 16-digit.</div>')
    }
  });

  /*END OF SWIPE CARD*/

  /*CVV CHOOSE OPTION*/
  $('#choose_option_cvv').on('click', function() {
    $('div[id="message"]').remove();

    $('#cvv').val('');
    $('div[id="modal_option_cvv"]')
    .modal({closable: false,
           autofocus: false,
           observeChanges: true})
           .modal('show');
  })

  /*CVV RETURN CHOOSE OPTION*/
  $('#choose_other_options_cvv').on('click', function() {
    $('div[id="modal_options"]')
    .modal({closable: false,
           autofocus: false,
           observeChanges: true})
           .modal('show');
  })

  $('input[id="cvv"]').on('keypress', function(evt){
    let theEvent = evt || window.event;
    let key = theEvent.keyCode || theEvent.which;
    key = String.fromCharCode( key );
    let regex = /[0-9]/;

    if($(this).val().length <= 1 && evt.keyCode == 32 || regex.test(key)){
      $(this).on('focusout', function(evt){
        $(this).val($(this).val().charAt(0).toUpperCase() + $(this).val().slice(1))
      })
    }else{
      return false;
    }
  })

  /*CVV AUTHENTICATE*/
  $('button[id="verify_loa_cvv"]').on('click', function(){
    let cvv = $('#cvv').val();
    let loa_id = $('input[id="loa_id"]').val();

    if (cvv.length == '3') {
      $.ajax({
        url: `/loas/${loa_id}/verify/cvv/${cvv}`,
        type: 'get',
        success: function(response) {
          console.log(response)

          if (response.valid == true) {
              alertify.success('<i class="close icon"></i><p>' + response.message + '</p>', 0);
            setTimeout(function() {
              document.location.href="/";
            }, 1000);
          } else {
            $('div[id="message"]').remove();
            $('p[role="append"]').append('<div id="message" class="ui negative message">' + response.message + '</div>')
          }
        }
      });
    }
    else if (cvv.length == '0') {
      $('div[id="message"]').remove()
      $('p[role="append"]').append('<div id="message" class="ui negative message">CVV is required.</div>')
    }
    else {
      $('div[id="message"]').remove()
      $('p[role="append"]').append('<div id="message" class="ui negative message">CVV should be 3-digit.</div>')
    }
  });

  /*END OF CVV*/

  /*OTP CHOOSE OPTION*/

  var otp_sent_code_interval;
  var otp_expiry_interval;

  $('#choose_option_otp').on('click', function() {
    $('div[id="message"]').remove();
    $('#otp').val('');
    let loa_id = $('input[id="loa_id"]').val();

    $.ajax({
      url: `/loas/${loa_id}/send_pin`,
      type: 'get',
      success: function(response) {
        $('div[id="modal_option_otp"]')
        .modal({closable: false,
             autofocus: false,
             observeChanges: true})
             .modal('show');

      /* Start of Timer */
        if (otp_sent_code_interval === undefined) {
        } else {
          clearTimeout(otp_sent_code_interval);
        }

        if (otp_expiry_interval === undefined) {
        } else {
          clearInterval(otp_expiry_interval);
        }

        $('#countdown_text').hide();
        $('#expired_text').hide();

        // Countdown timer for send new button
        // Set to 1 minute
        var diffTime2 = response.sent_code;
        var duration2 = moment.duration(diffTime2*1000, 'milliseconds');
        var interval2 = 1000;

        if(duration2.seconds() > 0){
          $('div[name="send_new_code"]').hide();
          otp_sent_code_interval = setTimeout(function(){
            $('div[name="send_new_code"]').show();
          }, duration2);
        }
        else{
          $('div[name="send_new_code"]').show();
        }

        // Countdown timer for pin expiry
        var diffTime = response.pin_expires_at;
        var duration = moment.duration(diffTime*1000, 'milliseconds');
        var interval = 1000;

        if(diffTime > 0){
          $('#countdown_text').hide()
          otp_expiry_interval = setInterval(function(){
            duration = moment.duration(duration - interval, 'milliseconds');
            let seconds = ""
            if(duration.seconds() < 0){
              $('#countdown_text').hide();
              $('#expired_text').show();
            }
            else if((duration.seconds() < 10) && (duration.seconds() >= 0)){
              seconds = '0' + duration.seconds()
              $('#countdown').text(duration.minutes() + ":" + seconds)
              $('#countdown_text').show();
              $('#expired_text').hide();
            }
            else{
              seconds = duration.seconds()
              $('#countdown').text(duration.minutes() + ":" + seconds)
              $('#countdown_text').show();
              $('#expired_text').hide();
            }
          }, interval);
        }
        else{
          $('#countdown_text').hide();
          $('#expired_text').show();
        }

      /* End of Timer */
      }
    });
  })

  /*OTP RETURN CHOOSE OPTION*/
  $('#choose_other_options_otp').on('click', function() {
    $('div[id="modal_options"]')
    .modal({closable: false,
           autofocus: false,
           observeChanges: true})
           .modal('show');
  })

  $('input[id="otp"]').on('keypress', function(evt){
    let theEvent = evt || window.event;
    let key = theEvent.keyCode || theEvent.which;
    key = String.fromCharCode( key );
    let regex = /[0-9]/;

    if($(this).val().length <= 1 && evt.keyCode == 32 || regex.test(key)){
      $(this).on('focusout', function(evt){
        $(this).val($(this).val().charAt(0).toUpperCase() + $(this).val().slice(1))
      })
    }else{
      return false;
    }
  })

  /*OTP AUTHENTICATE*/
  $('button[id="verify_loa_otp"]').on('click', function(){
    let otp = $('#otp').val();
    let loa_id = $('input[id="loa_id"]').val();

    if (otp.length == '4') {
      $.ajax({
        url: `/loas/validate_pin/${loa_id}/${otp}`,
        type: 'get',
        success: function(response) {
          console.log(response)

          if (response.valid == true) {
              alertify.success('<i class="close icon"></i><p>' + response.message + '</p>', 0);
            setTimeout(function() {
              document.location.href="/";
            }, 1000);
          } else {
            $('div[id="message"]').remove();
            $('p[role="append"]').append('<div id="message" class="ui negative message">' + response.message + '</div>')
          }
        }
      });
    }
    else if (otp.length == '0') {
      $('div[id="message"]').remove()
      $('p[role="append"]').append('<div id="message" class="ui negative message">OTP is required.</div>')
    }
    else {
      $('div[id="message"]').remove()
      $('p[role="append"]').append('<div id="message" class="ui negative message">OTP should be 4-digit.</div>')
    }
  });

  $('#resend_code_btn').on('click', function() {
    let loa_id = $('#loa_id').val()
    $.ajax({
      url: `/loas/${loa_id}/send_pin`,
      type: 'get',
      success: function(response) {
        /* Start of Timer */
        if (otp_sent_code_interval === undefined) {
        } else {
          clearTimeout(otp_sent_code_interval);
        }

        if (otp_expiry_interval === undefined) {
        } else {
          clearInterval(otp_expiry_interval);
        }

        $('#countdown_text').hide();
        $('#expired_text').hide();

        // Countdown timer for send new button
        // Set to 1 minute
        var diffTime2 = response.sent_code;
        var duration2 = moment.duration(diffTime2*1000, 'milliseconds');
        var interval2 = 1000;

        if(duration2.seconds() > 0){
          $('div[name="send_new_code"]').hide();
          otp_sent_code_interval = setTimeout(function(){
            $('div[name="send_new_code"]').show();
          }, duration2);
        }
        else{
          $('div[name="send_new_code"]').show();
        }

        // Countdown timer for pin expiry
        var diffTime = response.pin_expires_at;
        var duration = moment.duration(diffTime*1000, 'milliseconds');
        var interval = 1000;

        if(diffTime > 0){
          $('#countdown_text').hide()
          otp_expiry_interval = setInterval(function(){
            duration = moment.duration(duration - interval, 'milliseconds');
            let seconds = ""
            if(duration.seconds() < 0){
              $('#countdown_text').hide();
              $('#expired_text').show();
            }
            else if((duration.seconds() < 10) && (duration.seconds() >= 0)){
              seconds = '0' + duration.seconds()
              $('#countdown').text(duration.minutes() + ":" + seconds)
              $('#countdown_text').show();
              $('#expired_text').hide();
            }
            else{
              seconds = duration.seconds()
              $('#countdown').text(duration.minutes() + ":" + seconds)
              $('#countdown_text').show();
              $('#expired_text').hide();
            }
          }, interval);
        }
        else{
          $('#countdown_text').hide();
          $('#expired_text').show();
        }

      /* End of Timer */
      }
    })
  });

  /*END OF OTP*/
});

