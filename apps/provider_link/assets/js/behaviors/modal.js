var ac_sent_code_interval;
var ac_expiry_interval;

onmount('div[role="verification_modal"]', function () {
  $('div[role="verification_modal"]')
    .modal('setting', 'closable', false)
    .modal('show');

  $('#countdown_text').hide();
  $('#expired_text').hide();

  // Countdown timer for send new button
  // Set to 1 minute
  var diffTime2 = $('#sent_code').val();
  var duration2 = moment.duration(diffTime2*1000, 'milliseconds');
  var interval2 = 1000;

  if(duration2.seconds() > 0){
    $('div[name="send_new_code"]').hide();
    ac_sent_code_interval = setTimeout(function(){
        $('div[name="send_new_code"]').show();
    }, duration2);
    }
  else{
    $('div[name="send_new_code"]').show();
  }

  // Countdown timer for pin expiry
  var diffTime = $('#duration').val();
  var duration = moment.duration(diffTime*1000, 'milliseconds');
  var interval = 1000;

  if(diffTime > 0){
    $('#countdown_text').hide()
    ac_expiry_interval = setInterval(function(){
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

  $('div[id="verify_code"]').click(function () {
    if ($('input[name="security_code"]').val() == ""){
      $('div[id="verification"]').addClass("error");
      $('input[name="security_code"]').after("<div id='error_msg' class='ui basic red pointing prompt label transition visible'>Please enter Security Code</div>");
    }else{
      $('div[id="verification"]').removeClass("error");
      $('div[id="error_msg"]').remove();

    let agent_id = $(this).attr('agentID');
    let csrf = $('input[name="_csrf_token"]').val();
    let params = {
      security_code: $('input[name="security_code"]').val(),
    }

    $.ajax({
      url: `/activate/${agent_id}/verify`,
      headers: {"X-CSRF-TOKEN": csrf},
      data: {user: params},
      type: 'POST',
      success: function(response){
        if (response == "valid") {
          $('div[role="verify_success"]')
            .modal('setting', 'closable', false)
            .modal('show');
        } else if (response == "invalid") {
          $('p[id="error_msg"]').text('The verification code you entered is incorrect.')
          $('div[role="verify_failed"]')
            .modal('setting', 'closable', false)
            .modal('show');
        } else if (response == "pin_expired") {
          $('p[id="error_msg"]').text('Verification Code has already expired. Please click Send me a New Code link.')
          $('div[role="verify_failed"]')
            .modal('setting', 'closable', false)
            .modal('show');
        }
       }
     });
  }

  });

    $('button[id="verify_retry_btn"]').click(function() {
      $('input[name="security_code"]').val('');

      $('div[role="verification_modal"]')
          .modal('setting', 'closable', false)
          .modal('show');
    });

    $('button[id="verify_continue_btn"]').click(function() {
        window.location.href = '/sign_in';
    });

    $('a[id="resend_code_btn"]').click(function () {
      let agent_id = $(this).attr('agentID');
      let csrf = $('input[name="_csrf_token"]').val();

      $.ajax({
        url: `/activate/${agent_id}/new_code`,
        headers: {"X-CSRF-TOKEN": csrf},
        type: 'POST',
        success: function(response){
          let data = JSON.parse(response);

          if (data.status == "valid") {

          if (ac_sent_code_interval === undefined) {
          } else {
            clearTimeout(ac_sent_code_interval);
          }

          if (ac_expiry_interval === undefined) {
          } else {
            clearInterval(ac_expiry_interval);
          }

  // Countdown timer for send new button
  // Set to 1 minute
  var diffTime2 = data.sent_code;
  var duration2 = moment.duration(diffTime2*1000, 'milliseconds');
  var interval2 = 1000;

  if(duration2.seconds() > 0){
    $('div[name="send_new_code"]').hide();
    ac_sent_code_interval = setTimeout(function(){
        $('div[name="send_new_code"]').show();
    }, duration2);
    }
  else{
    $('div[name="send_new_code"]').show();
  }

  // Countdown timer for pin expiry
  var diffTime = data.duration;
  var duration = moment.duration(diffTime*1000, 'milliseconds');
  var interval = 1000;

  if(diffTime > 0){
    $('#countdown_text').hide()
    ac_expiry_interval = setInterval(function(){
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

          }
        }
      });
    });

    $('button[id="verify_new_code_btn"]').click(function () {
      let agent_id = $(this).attr('agentID');
      let csrf = $('input[name="_csrf_token"]').val();

      $.ajax({
        url: `/activate/${agent_id}/new_code`,
        headers: {"X-CSRF-TOKEN": csrf},
        type: 'POST',
        success: function(response){
          let data = JSON.parse(response);

          if (data.status == "valid") {
            $('input[name="security_code"]').val('');
            $('div[role="verification_modal"]')
            .modal('setting', 'closable', false)
            .modal('show');

          if (ac_sent_code_interval === undefined) {
          } else {
            clearTimeout(ac_sent_code_interval);
          }

          if (ac_expiry_interval === undefined) {
          } else {
            clearInterval(ac_expiry_interval);
          }

  // Countdown timer for send new button
  // Set to 1 minute
  var diffTime2 = data.sent_code;
  var duration2 = moment.duration(diffTime2*1000, 'milliseconds');
  var interval2 = 1000;

  if(duration2.seconds() > 0){
    $('div[name="send_new_code"]').hide();
    ac_sent_code_interval = setTimeout(function(){
        $('div[name="send_new_code"]').show();
    }, duration2);
    }
  else{
    $('div[name="send_new_code"]').show();
  }

  // Countdown timer for pin expiry
  var diffTime = data.duration;
  var duration = moment.duration(diffTime*1000, 'milliseconds');
  var interval = 1000;

  if(diffTime > 0){
    $('#countdown_text').hide()
    ac_expiry_interval = setInterval(function(){
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

          }
        }
      });
    });

});



// onmount('div[id="mobile_verification_form"]', function () {
//   $('#mobile_verification_form').form({
//     inline: true,
//     on: 'blur',
//     fields: {
//       'verification_code': {
//         identifier: 'verification_code',
//         rules: [{
//           type: 'empty',
//           prompt: 'Please enter your verification code'
//         }]
//       },
//     },
//   });


// });


onmount('div[role="forgot_password_verification_modal"]', function () {
  $('div[role="forgot_password_verification_modal"]')
    .modal('setting', 'closable', false)
    .modal('show');

  $('#countdown_text').hide();
  $('#expired_text').hide();

  // Countdown timer for pin expiry
  var diffTime = $('#duration').val()
  var duration = moment.duration(diffTime*1000, 'milliseconds');
  var interval = 1000;

  if(diffTime > 0){
    $('#countdown_text').hide()
    setInterval(function(){
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

  $('div[id="verify_code"]').click(function () {
    if ($('input[name="verification_code"]').val() == ""){

      $('div[id="verification"]').addClass("error");
      $('input[name="verification_code"]').after("<div id='error_msg' class='ui basic red pointing prompt label transition visible'>Please enter Security Code</div>");

    }else{

      $('div[id="verification"]').removeClass("error");
      $('div[id="error_msg"]').remove();
    let csrf = $('input[name="_csrf_token"]').val();
    let params = {
      agent_id: $(this).attr('agentID'),
      verification_code: $('input[name="verification_code"]').val()
    }

    $.ajax({
      url: `/forgot_password/verify`,
      headers: {"X-CSRF-TOKEN": csrf},
      data: {user: params},
      type: 'POST',
      success: function(response){
        if (response == "valid") {
          $('div[role="verify_success"]')
            .modal('setting', 'closable', false)
            .modal('show');
        } else if (response == "invalid") {
          $('p[id="error_msg"]').text('The verification code you entered is incorrect.')
          $('div[role="verify_failed"]')
            .modal('setting', 'closable', false)
            .modal('show');
        } else if (response == "pin_expired") {
          $('p[id="error_msg"]').text('Verification Code has already expired. Please click Send me a New Code link.')
          $('div[role="verify_failed"]')
            .modal('setting', 'closable', false)
            .modal('show');
        }
      }
    });
    }
  });

    $('button[id="verify_retry_btn"]').click(function() {
      $('input[name="verification_code"]').val('');
      $('div[role="forgot_password_verification_modal"]')
        .modal('setting', 'closable', false)
        .modal('show');
    });

    $('button[id="verify_continue_btn"]').click(function() {
        let user_id = $(this).attr('userID');
        window.location.href = '/reset_password/' + user_id;
    });

    $('button[id="verify_new_code_btn"]').click(function () {
        window.location.href = '/forgot_password';
    });

});


onmount('div[role="register_failed_modal"]', function() {
    $('div[role="register_failed_modal"]')
        .modal('setting', 'closable', false)
        .modal('show');

    $('button[id="register_retry_btn"]').click(function() {
        $('div[role="register_failed_modal"]')
            .modal('hide');
    });

});

onmount('div[role="register_success_modal"]', function() {
    $('div[role="register_success_modal"]')
        .modal('setting', 'closable', false)
        .modal('show');


    $('button[id="register_continue_btn"]').click(function() {
        window.location.href = '/sign_in';
    });
});

onmount('div[role="diagnosis_modal"]', function() {
    $('#add_diagnosis').on('click', function() {
        $('div[role="diagnosis_modal"]')
            .modal({
                closable: false,
                observeChanges: true
            })
            .modal('show');
    });
});

onmount('#loa_show', function() {

  $('#verify_loa').form({
    inline: true,
    on: 'blur',
    fields: {
      'loa[admission_date]': {
        identifier: 'loa[admission_date]',
        rules: [{
          type  : 'empty',
          prompt: 'Please enter Admission Date'
        },]
      },
      'loa[discharge_date]': {
        identifier: 'loa[discharge_date]',
        rules: [{
          type  : 'empty',
          prompt: 'Please enter Discharge Date'
        },
        {
          type  : 'GreaterThanAdmissionDate[param]',
          prompt: 'Discharge Date must be greater than or equal to the Admission Date'
        }
        ]
      }
    }
  })

  $('#reschedule_button').on('click', function() {
    console.log(123)
       $('#rescheduled_loa_modal')
    .modal({
      closable: true,
      autofocus: false,
      observeChanges: true
    })
    .modal('show')
  })

 $('#no_reschedule_loa_button').on('click', function() {
  $('#reschedule_modal').modal('hide')
  })

  $('#yes_reschedule_loa_button').on('click', function() {
    let authorization_id = $(this).attr('authorization_id')
    console.log(authorization_id)
    const csrf = $('input[name="_csrf_token"]').val();
    $.ajax({
      url: `/loas/${authorization_id}/reschedule_loa`,
      headers: {"X-CSRF-TOKEN": csrf},
      type: 'get',
      success: function(response){
        alertify.success(`<i class="close icon"></i> <p> Sucessfully Reschedule LOA </p>`);
        window.location.replace(`/loas/${response.loa_id}/show_consult/show_success`)
      }})
  })


    // let consult_date = new Date($('#consult_date').html())
    // let consultation_date = moment(consult_date).format("Do MMMM, YYYY")
    // $('#consult_date').html(consultation_date)
    // $('#consult_date_main').html(consultation_date)
    // $('#consult_date_success').html(consultation_date)
    // $('#consult_date_fail').html(consultation_date)
    $('#cancel_loa').on('click', function() {
        $('div#cancel_main_modal')
            .modal({
                closable: false,
                observeChanges: true
            })
            .modal('show');
    });
    $('#success_close').on('click', function() {
        $('div#cancel_success_modal')
            .modal({
                closable: false,
                observeChanges: true
            })
            .modal('close');

        let loa_id = $('#loa_id').val()
        let loe_no = $('#loe_no').val()
        let session = $('#session').val()
        let loa_coverage = $('#coverage').val()
        if(session == "no"){
          let paylink_id = $('input[name="loa[paylink_user_id]"]').val()
          window.location.href = '/loas/' + loe_no + '/show_loa_no_session/' + paylink_id;
        }
        else {
          if(loa_coverage == "op consult"){
            window.location.href = `/loas/${loa_id}/show_consult`
          }
          else{
            window.location.href = `/loas/${loa_id}/show`
          }
        }
    });
    $('#fail_close').on('click', function() {
        $('#cancel_fail_modal').modal('close');
    });

    $('#cancel').on('click', function() {

        let lab = $('#loa_id').val()

        $.ajax({
            url: `/loas/${lab}/cancel`,
            type: 'get',
            success: function(response) {
                if (response.message == "success") {
                    $('#cancel_main_modal').modal({
                        transition: 'fade right',
                        closable: false,
                        observeChanges: true
                    }).modal('close')
                    $('#cancel_success_modal').attr('class', 'ui tiny modal')
                    $('#cancel_success_modal').modal({
                        transition: 'fade right',
                        closable: false,
                        observeChanges: true
                    }).modal('show')
                } else if (response.message == "fail") {
                    $('#cancel_main_modal').modal({
                        transition: 'fade right',
                        closable: false,
                        observeChanges: true
                    }).modal('close')
                    $('#cancel_fail_modal').attr('class', 'ui tiny modal')
                    $('#cancel_fail_modal').modal({
                        transition: 'fade right',
                        closable: false,
                        observeChanges: true
                    }).modal('show')
                }
            }
        })
    })
});

onmount('div[role="reset_password"]', function () {
  $('div[role="success_modal"]')
    .modal('setting', 'closable', false)
    .modal('show');

  $('button[id="continue_btn"]').click(function() {
      window.location.href = '/';
  });

});

onmount('div[id="loa_show"]', function(){
  $('#view_evoucher').click(function(){
    $('#evoucher_modal').modal('show')
    $('#qrcode_evoucher').find('canvas').remove()
    $('#qrcode_evoucher').qrcode({
      width: 180,
      height: 180,
      text: $('#member_qrcode').val()
    })
  })
    $('#print_qrcode_evoucher').qrcode({
      width: 180,
      height: 180,
      text: $('#member_qr_code_evoucher').val()
    })
    let canvas = $('#print_qrcode_evoucher').find('canvas')[0].toDataURL();
    $('#input_print_qrcode_evoucher').val(canvas)

  if($('#dwonload_evoucher_pdf').attr('attrRO') != "disabled"){
    $('#dwonload_evoucher_pdf').click(function(){
      $('#submit_print_evoucher').submit()
    })
  }

})
