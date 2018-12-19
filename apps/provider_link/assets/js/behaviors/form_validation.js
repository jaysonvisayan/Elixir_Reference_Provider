onmount('div[role="register_user"]', function() {

  $('input[name="agent[first_name]"]').on('keypress', function(evt){
    let theEvent = evt || window.event;
    let key = theEvent.keyCode || theEvent.which;
    key = String.fromCharCode( key );
    let regex = /[0-9``~<>^'{}[\]\\;':"/?!@#$%&*_+()=,]/;

    if($(this).val().length <= 1 && evt.keyCode == 32 || regex.test(key)){
      return false;
    }else{
      $(this).on('focusout', function(evt){
        $(this).val($(this).val().charAt(0).toUpperCase() + $(this).val().slice(1))
      })
    }
  });

  $('input[name="agent[middle_name]"]').on('keypress', function(evt){
    let theEvent = evt || window.event;
    let key = theEvent.keyCode || theEvent.which;
    key = String.fromCharCode( key );
    let regex = /[0-9``~<>^'{}[\]\\;':"/?!@#$%&*_+()=,]/;

    if($(this).val().length <= 1 && evt.keyCode == 32 || regex.test(key)){
      return false;
    }else{
      $(this).on('focusout', function(evt){
        $(this).val($(this).val().charAt(0).toUpperCase() + $(this).val().slice(1))
      })
    }
  });

  $('input[name="agent[last_name]"]').on('keypress', function(evt){
    let theEvent = evt || window.event;
    let key = theEvent.keyCode || theEvent.which;
    key = String.fromCharCode( key );
    let regex = /[0-9``~<>^'{}[\]\\;':"/?!@#$%&*_+()=,]/;

    if($(this).val().length <= 1 && evt.keyCode == 32 || regex.test(key)){
      return false;
    }else{
      $(this).on('focusout', function(evt){
        $(this).val($(this).val().charAt(0).toUpperCase() + $(this).val().slice(1))
      })
    }
  });

  $('input[name="agent[extension]"]').on('keypress', function(evt){
    let theEvent = evt || window.event;
    let key = theEvent.keyCode || theEvent.which;
    key = String.fromCharCode( key );
    let regex = /[0-9``~<>^'{}[\]\\;':"/?!@#$%&*_+()=,-]/;

    if($(this).val().length <= 1 && evt.keyCode == 32 || regex.test(key)){
      return false;
    }else{
      $(this).on('focusout', function(evt){
        $(this).val($(this).val().charAt(0).toUpperCase() + $(this).val().slice(1))
      })
    }
  });

  $('input[name="agent[department]"]').on('keypress', function(evt){
    let theEvent = evt || window.event;
    let key = theEvent.keyCode || theEvent.which;
    key = String.fromCharCode( key );
    let regex = /[0-9``~<>^'{}[\]\\;':"/?!@#$%&*_+=,]/;

    if($(this).val().length <= 1 && evt.keyCode == 32 || regex.test(key)){
      return false;
    }else{
      $(this).on('focusout', function(evt){
        $(this).val($(this).val().charAt(0).toUpperCase() + $(this).val().slice(1))
      })
    }
  });

  $('input[name="agent[role]"]').on('keypress', function(evt){
    let theEvent = evt || window.event;
    let key = theEvent.keyCode || theEvent.which;
    key = String.fromCharCode( key );
    let regex = /[0-9``~<>^'{}[\]\\;':"/?!@#$%&*_+=,]/;

    if($(this).val().length <= 1 && evt.keyCode == 32 || regex.test(key)){
      return false;
    }else{
      $(this).on('focusout', function(evt){
        $(this).val($(this).val().charAt(0).toUpperCase() + $(this).val().slice(1))
      })
    }
  });

  $.fn.form.settings.rules.mobileExists = function(param) {
    param = param.replace(/-/g, '');

    if(param == ""){
      return true;
    }else{

      if($('input[id="mobiles"]').val() == "" || $('input[id="mobiles"]').val() == null){
        return true;
      }else{
        var mobiles = JSON.parse($('input[id="mobiles"]').val());

        if (jQuery.inArray(param, mobiles) < 0) {
          return true;
        } else {
          return false;
        }
      }
    }
  }

  $.fn.form.settings.rules.validateMobile = function(param) {

    if (param == '') {
      return true;
    } else {

      param = param.replace(/-/g, '');
      if (/^0[0-9]{10}$/.test(param)) {
        return true;
      } else {
        return false;
      }
    }
  }

  $.fn.form.settings.rules.emailExists = function(param) {
    if(param == ""){
      return true;
    }else{

      if($('input[id="emails"]').val() == "" || $('input[id="emails"]').val() == null){
        return true;
      }else{
        var mobiles = JSON.parse($('input[id="emails"]').val());

        if (jQuery.inArray(param, mobiles) < 0) {
          return true;
        } else {
          return false;
        }
      }
    }
  }

  $('#register_form').form({
    inline: true,
    on: 'blur',
    fields: {
      'agent[first_name]': {
        identifier: 'agent[first_name]',
        rules:
        [{
          type: 'empty',
          prompt: 'Please enter first name'
        },
        {
          type: 'regExp[/^[ña-zÑA-Z .-]*$/]',
          prompt: 'The first name you have entered is invalid'
        }]
      },
      'agent[middle_name]': {
        identifier: 'agent[middle_name]',
        rules:
        [{
          type: 'regExp[/^[ña-zÑA-Z .-]*$/]',
          prompt: 'The middle name you have entered is invalid'
        }]
      },
      'agent[last_name]': {
        identifier: 'agent[last_name]',
        rules:
        [{
          type: 'empty',
          prompt: 'Please enter last name'
        },
        {
          type: 'regExp[/^[ña-zÑA-Z .-]*$/]',
          prompt: 'The last name you have entered is invalid'
        }]
      },
      'agent[extension]': {
        identifier: 'agent[extension]',
        rules:
        [{
          type: 'regExp[/^[ña-z.ÑA-Z .]*$/]',
          prompt: 'The extension you have entered is invalid'
        }]
      },
      'agent[provider_id]': {
        identifier: 'agent[provider_id]',
        rules:
        [{
          type: 'empty',
          prompt: 'Please enter provider'
        }]
      },
      'agent[department]': {
        identifier: 'agent[department]',
        rules:
        [{
          type: 'empty',
          prompt: 'Please enter department'
        },
        {
          type: 'regExp[/^[ña-zÑA-Z .()-]*$/]',
          prompt: 'The department you have entered is invalid'
        }]
      },
      'agent[role]': {
        identifier: 'agent[role]',
        rules:
        [{
          type: 'empty',
          prompt: 'Please enter role'
        },
        {
          type: 'regExp[/^[ña-zÑA-Z .()-]*$/]',
          prompt: 'The role you have entered is invalid'
        }]
      },
      'agent[mobile]': {
        identifier: 'agent[mobile]',
        rules:
        [{
          type: 'empty',
          prompt: 'Please enter mobile'
        },
        {
          type: 'validateMobile[param]',
          prompt: 'The mobile number you have entered is invalid'
        },
        {
          type: 'mobileExists[param]',
          prompt: 'The mobile number you have entered is already registered'
        }]
      },
      'agent[email]': {
        identifier: 'agent[email]',
        rules:
        [{
          type: 'empty',
          prompt: 'Please enter email'
        },
        {
          type: 'regExp[/^[A-Za-z0-9._,-]+@[A-Za-z0-9._,-]+\.[A-Za-z]{2,4}$/]',
          prompt: 'The email you have entered is invalid'
        },
        {
          type: 'emailExists[param]',
          prompt: 'The email addres you have entered is already registered'
        }]
      },
    },
  });

});

onmount('div[role="activate_user"]', function() {

  $('input[name="user[username]"]').on('keypress', function(evt){
    let theEvent = evt || window.event;
    let key = theEvent.keyCode || theEvent.which;
    key = String.fromCharCode( key );
    let regex = /[``~<>^'{}[\]\\;':"/?!@#$%&*+()=,]/;

    if($(this).val().length <= 1 && evt.keyCode == 32 || regex.test(key)){
      return false;
    }else{
      return true;
    }
  });

  // $('#submit_user_button').click(function(){
  //   const csrf = $('input[name="_csrf_token"]').val();
  //   $.ajax({
  //     url: `/activate/user/validate_username`,
  //     headers: {"X-CSRF-TOKEN": csrf},
  //     type: 'post',
  //     data: {username: $('input[id="user_username"]').val()},
  //     dataType: 'json',
  //     success: function(response){
  //       if (response == "true"){
  //         return true;
  //       }else{
  //         return false;
  //       }
  //     }
  //   })
  // })

  // $.fn.form.settings.rules.usernameTaken = function(param) {
  //   if (param == "") {
  //     return true;
  //   } else {
  //     if ($('input[id="usernames"]').val() == "" || $('input[id="usernames"]').val() == null) {
  //       return true;
  //     } else {
  //       var usernames = JSON.parse($('input[id="usernames"]').val());
  //       if (jQuery.inArray(param, usernames) < 0) {
  //         return true;
  //       } else {
  //         return false;
  //       }
  //     }
  //   }
  // }
  //
  $('#submit_user_button').click(function(){
      const csrf = $('input[name="_csrf_token"]').val();
      let ajax_data = $.ajax({
        url: `/activate/user/validate_username`,
        headers: {"X-CSRF-TOKEN": csrf},
        type: 'post',
        data: {username: $('#user_username').val()},
        dataType: 'json',
        success: function(response){
          if (response == "true") {
            $('#new_form_user').submit()
          }else{
            $('#append').find('.ui.basic.red.pointing.prompt.label.transition.visible').remove()
            $('#append').append('<div class="ui basic red pointing prompt label transition visible">Username is already taken</div>')
            $('#append').addClass('error')
          }
        }
    })
  })

  $('#activate_form').form({
    inline: true,
    on: 'blur',
    fields: {
      'user[username]': {
        identifier: 'user[username]',
        rules: [{
          type: 'empty',
          prompt: 'Please enter username'
        },
        // {
        //   type: 'usernameTaken[param]',
        //   prompt: 'Username is already taken'
        // },
        {
          type: 'minLength[8]',
          prompt: 'Please enter at least 8 characters'
        },
        {
          type: 'maxLength[20]',
          prompt: 'Please enter at most 20 characters'
        },
        {
          type: 'regExp[/^[0-9ña-zÑA-Z ._-]*$/]',
          prompt: 'The username you have entered is invalid'
        }]
      },
      'user[password]': {
        identifier: 'user[password]',
        rules: [{
          type: 'empty',
          prompt: 'Please enter password'
        },
        {
          type: 'regExp[/(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).{8,}/]',
          prompt: 'Password must be at least 8 characters and should contain alpha-numeric, special-character, atleast 1 capital letter'
        }]
      },
      'user[password_confirmation]': {
        identifier: 'user[password_confirmation]',
        rules: [{
          type: 'empty',
          prompt: 'Please enter confirm password'
        },
        {
          type: 'match[user[password]]',
          prompt: 'Passwords do not match'
        }]
      },
    }
  });

});

onmount('div[id="number_modal"]', function() {

    $('a#consult').on('click', function() {
        $('#link').val("consult")
        $('#link2').val("consult")
        $('#number_modal').attr('class', 'ui tiny modal');
        $('#number_modal').modal('show')
    })

    $('a#lab').on('click', function() {
        $('#link').val("lab")
        $('#link2').val("lab")
        $('#number_modal').attr('class', 'ui tiny modal');
        $('#number_modal').modal('show')
    })

    $('a#ip').on('click', function() {
        $('#link').val("ip")
        $('#link2').val("ip")
        $('#number_modal').attr('class', 'ui tiny modal');
        $('#number_modal').modal('show')
    })

    $('a#er').on('click', function() {
        $('#link').val("er")
        $('#link2').val("er")
        $('#number_modal').attr('class', 'ui tiny modal');
        $('#number_modal').modal('show')
    })

    $('a#peme').on('click', function() {
        $('#link').val("peme")
        $('#link2').val("peme")
        $('#number_modal').attr('class', 'ui tiny modal');
        $('#number_modal').modal('show')
    })


    $('#validate').on('click', function() {
        let cardno1 = $('input[name="cardno1"]').val()
        let cardno2 = $('input[name="cardno2"]').val()
        let cardno3 = $('input[name="cardno3"]').val()
        let cardno4 = $('input[name="cardno4"]').val()
        $('#card').val(cardno1 + cardno2 + cardno3 + cardno4)

        let card = $('#card').val()
        let error = '<div id="message" class="ui negative message"><ul class="list">'

        if ($('#card').val() == "") {
            $('div[id="message"]').remove()
            $('p[role="append"]').append(error + '<li>Card number is required.</li> </ul> </div>')
        } else {

            $.ajax({
                url: `/members/card/${card}`,
                type: 'get',
                success: function(response) {
                    if (response.message == "Card Number is required") {
                        $('div[id="message"]').remove()
                        $('p[role="append"]').append(error + '<li>' + response.message + '</li> </ul> </div>')
                    } else if (response.message == "PayorLink Internal Server Error") {
                        $('div[id="message"]').remove()
                        $('p[role="append"]').append(error + '<li>' + response.message + '</li> </ul> </div>')
                    } else if (response.message == "Card Number should be 16-digit") {
                        $('div[id="message"]').remove()
                        $('p[role="append"]').append(error + '<li>' + response.message + '</li> </ul> </div>')
                    } else if (response.message == "Card Number does not exist") {
                        $('div[id="message"]').remove()
                        $('p[role="append"]').append(error + '<li>' + "Card Number does not exist" + '</li> </ul> </div>')
                    } else if (response.message == "Member not eligible") {
                        $('div[id="message"]').remove()
                        $('p[role="append"]').append(error + '<li>' + response.message + '</li> </ul> </div>')
                    } else {
                        $('div[id="message"]').remove()
                        $('#number_modal').modal({
                            transition: 'fade right'
                        }).modal('close');
                        $('#confirm_cvv_modal').attr('class', 'ui tiny modal');
                        $('#card_number').html(response.number);
                        $('#member_name').html(response.name);
                        $('#number').val(response.number);
                        $('#confirm_cvv_modal').modal({
                            transition: 'fade right'
                        }).modal('show');
                        $('#enter_cvv').on('click', function() {
                            $('#member_id').val(response.id);
                            $('#confirm_cvv_modal').modal({
                                transition: 'fade right'
                            }).modal('close');
                            $('#cvv_modal').attr('class', 'ui tiny modal');
                            $('#cvv_modal').modal({
                                transition: 'fade right'
                            }).modal('show');;
                        })
                        $('#back_cvv').on('click', function() {
                            $('#confirm_cvv_modal').modal({
                                transition: 'fade right'
                            }).modal('close');
                            $('#number_modal').attr('class', 'ui tiny modal');
                            $('#number_modal').modal({
                                transition: 'fade right'
                            }).modal('show');
                        })

                    }


                }
            })
        }
    })

    $('#new_validation').on('click', function() {
        $('#number_modal').modal({
            transition: 'fade right'
        }).modal('close');
        $('#new_validation_modal').attr('class', 'ui tiny modal');
        $('#new_validation_modal').modal({
            transition: 'fade right'
        }).modal('show');

        $('#verify').on('click', function() {
            let full_name = $('#full_name').val()
            let birth_date = $('#birth_date').val()
            let error = '<div id="message" class="ui negative message"><ul class="list">'
            console.log(new Date())
            if ((full_name == "" && birth_date == "")) {
                $('div[id="message"]').remove()
                $('p[role="append_new"]').append(error + '<li>Full name and Birth date required.</li> </ul> </div>')
            } else if (birth_date == "") {
                $('div[id="message"]').remove()
                $('p[role="append_new"]').append(error + '<li>Birth date is required.</li> </ul> </div>')
            } else if (full_name == "") {
                $('div[id="message"]').remove()
                $('p[role="append_new"]').append(error + '<li>Full name is required.</li> </ul> </div>')
            } else {
                $.ajax({
                    url: `/members/${full_name}/${birth_date}`,
                    type: 'get',
                    success: function(response) {
                        if (response.message == "The Member Name or Birthdate you have entered is invalid") {
                            $('div[id="message"]').remove()
                            $('p[role="append_new"]').append(error + '<li>The Member Name or Birthdate you have entered is invalid</li> </ul> </div>')
                        } else if (response.message == "Member not eligible") {
                            $('div[id="message"]').remove()
                            $('p[role="append_new"]').append(error + '<li>Member not eligible</li> </ul> </div>')
                        } else if (response.message == "Invalid Input") {
                            $('div[id="message"]').remove()
                            $('p[role="append_new"]').append(error + '<li>Invalid Input.</li> </ul> </div>')
                        } else {
                            $('div[id="message"]').remove()
                            $('#member_id2').val(response.id);
                            $('#new_validation_modal').modal({
                                transition: 'fade right'
                            }).modal('close')
                            if (response.accounts == 1){
                            if((response.type == "principal") || (response.type == "guardian")){
                                //Define
                                var items = Array("f1", "f2", "f3", "f4", "f5", "f6");
                                var item = items[Math.floor(Math.random() * items.length)]

                                var index = items.indexOf(item)
                                if (index > -1) {
                                    items.splice(index, 1);
                                    if ((item != "f3") && (item != "f4")) {
                                        var f3 = items.indexOf("f3")
                                        if (f3 > -1) {
                                            items.splice(f3, 1);
                                        }
                                        var f4 = items.indexOf("f4")
                                        if (f4 > -1) {
                                            items.splice(f4, 1);
                                        }
                                    } else if (item == "f3") {
                                        var f4 = items.indexOf("f4")
                                        if (f4 > -1) {
                                            items.splice(f4, 1);
                                        }
                                    }
                                    if (item == "f4") {
                                        var f3 = items.indexOf("f3")
                                        if (f3 > -1) {
                                            items.splice(f3, 1);
                                        }
                                    }
                                }
                                var item2 = items[Math.floor(Math.random() * items.length)]
                                $('#first').append($('#' + item).html())
                                $('#' + item + 'a').show()
                                $('#first').find('select').attr("id", "first_question")
                                $('.dropdown').dropdown()
                                $('#second').append($('#' + item2).html())
                                $('#' + item2 + 'b').show()
                                $('#second').find('input').attr("id", "second_question")
                                // Email
                                if ($('#first').find('#f1a').length != 0) {
                                    var email_address = response.email_address
                                    var arr = email_address.split('@', 2)
                                    var birth_date = response.birth_date
                                    var arr2 = birth_date.split('-', 3)
                                    $('#first_question').append($('<option>', {
                                        value: response.email_address,
                                        text: response.email_address,
                                        class: "choices"
                                    }))
                                    $('#first_question').append($('<option>', {
                                        value: arr[0] + arr2[1] + arr[1],
                                        text: arr[0] + arr2[1] + arr[1],
                                        class: "choices"
                                    }))
                                    $('#first_question').append($('<option>', {
                                        value: arr[0] + arr2[1] + arr2[2] + arr[1],
                                        text: arr[0] + arr2[1] + arr2[2] + arr[1],
                                        class: "choices"
                                    }))
                                    $('#first_answer').val(response.email_address)
                                }
                                if ($('#second').find('#f1b').length != 0) {
                                    $('#second_answer').val(response.email_address)
                                }
                                // Mobile
                                var mobile = response.mobile
                                var mobile_last = mobile[mobile.length - 4] + mobile[mobile.length - 3] + mobile[mobile.length - 2] + mobile[mobile.length - 1]
                                if ($('#first').find('#f2a').length != 0) {
                                    $('#first_question').append($('<option>', {
                                        value: mobile_last,
                                        text: mobile_last,
                                        class: "choices"
                                    }))
                                    var mobile_random = [];
                                    for (var i = 1000; i <= 9999; i++) {
                                        mobile_random.push(i);
                                    }
                                    var mobile_index = mobile_random.indexOf(Number(mobile_last))
                                    mobile_random.splice(mobile_index, 1)
                                    var mr1 = mobile_random[Math.floor(Math.random() * mobile_random.length)]
                                    var mr_index = mobile_random.indexOf(mr1)
                                    if (mr_index > -1) {
                                        mobile_random.splice(mr_index, 1)
                                    }
                                    var mr2 = mobile_random[Math.floor(Math.random() * mobile_random.length)]
                                    $('#first_question').append($('<option>', {
                                        value: String(mr1),
                                        text: String(mr1),
                                        class: "choices"
                                    }))
                                    $('#first_question').append($('<option>', {
                                        value: String(mr2),
                                        text: String(mr2),
                                        class: "choices"
                                    }))
                                    $('#first_answer').val(mobile_last)
                                }
                                if ($('#second').find('#f2b').length != 0) {
                                    $('#second_answer').val(mobile_last)
                                }
                                //Dependents
                                let number_of_dependents = parseInt(response.number_of_dependents)
                                let dependents = ""
                                if (number_of_dependents > 0) {
                                    dependents = "Yes"
                                } else {
                                    dependents = "No"
                                }
                                if ($('#first').find('#f4a').length != 0) {
                                    $('#first_answer').val(dependents)
                                }
                                if ($('#second').find('#f4b').length != 0) {
                                    $('#second_answer').val(dependents)
                                }
                                if ($('#first').find('#f5a').length != 0) {
                                    $('#first_question').append($('<option>', {
                                        value: response.number_of_dependents,
                                        text: response.number_of_dependents,
                                        class: "choices"
                                    }))
                                    var dep_random = [];
                                    for (var x = 0; x <= 100; x++) {
                                        dep_random.push(x);
                                    }
                                    var dep_index = dep_random.indexOf(Number(number_of_dependents))
                                    dep_random.splice(dep_index, 1)
                                    var dp1 = dep_random[Math.floor(Math.random() * dep_random.length)]
                                    var dp_index = dep_random.indexOf(dp1)
                                    if (dp_index > -1) {
                                        dep_random.splice(dp_index, 1)
                                    }
                                    var dp2 = dep_random[Math.floor(Math.random() * dep_random.length)]
                                    $('#first_question').append($('<option>', {
                                        value: String(dp1),
                                        text: String(dp1),
                                        class: "choices"
                                    }))
                                    $('#first_question').append($('<option>', {
                                        value: String(dp2),
                                        text: String(dp2),
                                        class: "choices"
                                    }))
                                    $('#first_answer').val(response.number_of_dependents)
                                }
                                if ($('#second').find('#f5b').length != 0) {
                                    $('#second_answer').val(response.number_of_dependents)

                                }
                                if ($('#first').find('#f6a').length != 0) {
                                    $('#first_question').append($('<option>', {
                                        value: response.last_facility,
                                        text: response.last_facility,
                                        class: "choices"
                                    }))
                                var fc_random = response.facilities
                                var fc_index = fc_random.indexOf(response.last_facility)
                                fc_random.splice(fc_index, 1)
                                var fc1 = fc_random[Math.floor(Math.random() * fc_random.length)]
                                var fc_index = fc_random.indexOf(fc1)
                                if (fc_index > -1) {
                                    fc_random.splice(fc_index, 1)
                                }
                                var fc2 = fc_random[Math.floor(Math.random() * fc_random.length)]
                                    $('#first_question').append($('<option>', {
                                        value: fc1,
                                        text: fc1,
                                        class: "choices"
                                    }))
                                    $('#first_question').append($('<option>', {
                                        value: fc2,
                                        text: fc2,
                                        class: "choices"
                                    }))
                                $('#first_answer').val(response.last_facility)
                                }
                                if ($('#second').find('#f6b').length != 0) {
                                    $('#second_answer').val(response.last_facility)

                                }
                                //Consultations
                                let number_of_consultations = parseInt(response.number_of_consultations)
                                let consultations = ""
                                if (number_of_consultations > 0) {
                                    consultations = "Yes"
                                } else {
                                    consultations = "No"
                                }
                                if ($('#first').find('#f3a').length != 0) {
                                    $('#first_answer').val(consultations)
                                }
                                if ($('#second').find('#f3b').length != 0) {
                                    $('#second_answer').val(response.consultations)
                                }
                            } else if (response.type == "dependent") {
                                //Define
                                var items = Array("f1", "f2", "f3", "f7", "f8", "f6");
                                var item = items[Math.floor(Math.random() * items.length)]
                                var index = items.indexOf(item)
                                if (index > -1) {
                                    items.splice(index, 1);
                                    if (item != "f3") {
                                        var f3 = items.indexOf("f3")
                                        if (f3 > -1) {
                                            items.splice(f3, 1);
                                        }
                                    }
                                }
                                var item2 = items[Math.floor(Math.random() * items.length)]
                                $('#first').append($('#' + item).html())
                                $('#' + item + 'a').show()
                                $('#first').find('select').attr("id", "first_question")
                                $('.dropdown').dropdown()
                                $('#second').append($('#' + item2).html())
                                $('#' + item2 + 'b').show()
                                $('#second').find('input').attr("id", "second_question")
                                // Email
                                if ($('#first').find('#f1a').length != 0) {
                                    $('#first_question').append($('<option>', {
                                        value: response.email_address,
                                        text: response.email_address,
                                        class: "choices"
                                    }))
                                    $('#first_question').append($('<option>', {
                                        value: arr[0] + arr2[1] + arr2[2] + arr[1],
                                        text: arr[0] + arr2[1] + arr2[2] + arr[1],
                                        class: "choices"
                                    }))
                                    $('#first_answer').val(response.email_address)
                                }
                                if ($('#second').find('#f1b').length != 0) {
                                    $('#second_answer').val(response.email_address)
                                }
                                // Mobile
                                var mobile = response.mobile
                                var mobile_last = mobile[mobile.length - 4] + mobile[mobile.length - 3] + mobile[mobile.length - 2] + mobile[mobile.length - 1]
                                if ($('#first').find('#f2a').length != 0) {
                                    $('#first_question').append($('<option>', {
                                        value: mobile_last,
                                        text: mobile_last,
                                        class: "choices"
                                    }))
                                    $('#first_answer').val(mobile_last)
                                }
                                if ($('#second').find('#f2b').length != 0) {
                                    $('#second_answer').val(mobile_last)
                                }
                                //Dependents
                                if ($('#first').find('#f7a').length != 0) {
                                    $('#first_question').append($('<option>', {
                                        value: response.principal,
                                        text: response.principal,
                                        class: "choices"
                                    }))
                                    $('#first_answer').val(response.principal)
                                    if ($('#second').find('#f7b').length != 0) {
                                        $('#second_answer').val(response.principal)
                                    }
                                }
                                if ($('#first').find('#f8a').length != 0) {
                                    $('#first_question').append($('<option>', {
                                        value: response.relationship,
                                        text: response.relationship,
                                        class: "choices"
                                    }))
                                    $('#first_answer').val(response.relationship)
                                }
                                if ($('#second').find('#f8b').length != 0) {
                                    $('#second_answer').val(response.relationship)

                                }
                                //Consultations
                                let number_of_consultations = parseInt(response.number_of_consultations)
                                let consultations = ""
                                if (number_of_consultations > 0) {
                                    consultations = "Yes"
                                } else {
                                    consultations = "No"
                                }
                                if ($('#first').find('#f3a').length != 0) {
                                    $('#first_answer').val(consultations)
                                }
                                if ($('#second').find('#f3b').length != 0) {
                                    $('#second_answer').val(response.consultations)
                                }
                            }
                                $('#submit_security').on('click', function() {
                                let first_question = $('#first_question').find(":selected").text()
                                let second_question = $('#second_question').val()
                                if (first_question == "") {
                                    $('#first_question').parent().removeClass('error')
                                    $('#first').find('.prompt').remove()
                                    $('#first_question').parent().addClass('error')
                                    $('#first').append(`<div class="ui basic red pointing prompt label transition visible">Please select an answer</div>`)
                                    $('p[role="append_security"]').empty()
                                }
                                if (second_question == "") {
                                    $('#second_question').parent().removeClass('error')
                                    $('#second').find('.prompt').remove()
                                    $('#second_question').parent().addClass('error')
                                    $('#second').append(`<div class="ui basic red pointing prompt label transition visible">Please enter an answer</div>`)
                                    $('p[role="append_security"]').empty()
                                }
                                if ((first_question != "" && second_question != "")) {
                                    $('#first_question').parent().removeClass('error')
                                    $('#first').find('.prompt').remove()
                                    $('#second_question').parent().removeClass('error')
                                    $('#second').find('.prompt').remove()
                                    if (($('#first_question').find(":selected").text() == $('#first_answer').val()) && ($('#second_question').val() == $('#second_answer').val())) {
                                        let member_id = $('#member_id2').val()
                                        $.ajax({
                                            url: `/members/${member_id}/send_pin`,
                                            type: 'get',
                                            success: function(response) {
                                                $('#pin_modal').attr('class', 'ui tiny modal');
                                                $('#pin_modal').modal({
                                                    transition: 'fade right'
                                                }).modal('show')
                                            }
                                        })
                                    } else {
                                        $('div[id="message"]').remove()
                                        $('p[role="append_security"]').append(error + '<li>Oops! Wrong Answer Please Try Again!</li> </ul> </div>')
                                    }
                                    $("#first_question").on('keyup', function(e) {
                                        if ($(this).val().length > 0) {
                                            $('#first_question').parent().removeClass('error')
                                            $('#first').find('.prompt').remove()
                                        }
                                    })
                                    $("#second_question").on('keyup', function(e) {
                                        if ($(this).val().length > 0) {
                                            $('#second_question').parent().removeClass('error')
                                            $('#second').find('.prompt').remove()
                                        }
                                    })
                                }
                            })
                            $('#security_modal').attr('class', 'ui tiny modal');
                            $('#security_modal').modal({
                                transition: 'fade right'
                            }).modal('show')
                            jQuery.fn.shuffle = function() {
                                var j;
                                for (var k = 0; k < this.length; k++) {
                                    j = Math.floor(Math.random() * this.length);
                                    $(this[k]).before($(this[j]));
                                }
                                return this;
                            };
                            $('#first_question option.choices').shuffle();
                        }
                        else{
                            let account_names = []
                            $.map(response.member, function(member, index) {
                                account_names.push(member.account_name)
                            })
                            let account_codes = []
                            $.map(response.member, function(member, index) {
                                account_codes.push(member.account_code)
                            })
                                var item = "f3"
                                var items = Array("f9", "f10", "f6");
                                var item2 = "f9"
                                $('#first').append($('#' + item).html())
                                $('#' + item + 'a').show()
                                $('#first').find('select').attr("id", "first_question")
                                $('.dropdown').dropdown()
                                $('#second').append($('#' + item2).html())
                                $('#' + item2 + 'b').show()
                                $('#second').find('input').attr("id", "second_question")

                                let number_of_consultations = parseInt(response.number_of_consultations)
                                let consultations = ""
                                if (number_of_consultations > 0) {
                                    consultations = "Yes"
                                } else {
                                    consultations = "No"
                                }
                                if ($('#first').find('#f3a').length != 0) {
                                    $('#first_answer').val(consultations)
                                }
                                // Account Code
                                if ($('#second').find('#f9b').length != 0) {
                                    $('#second_answer').val(account_codes)
                                }
                                if ($('#second').find('#f10b').length != 0) {
                                    $('#second_answer').val(account_names)
                                }

                                let name = []
                                $.map(response.member, function(member, index) {
                                    name.push(member.name)
                                })
                                let birth_date = []
                                $.map(response.member, function(member, index) {
                                    birth_date.push(member.birth_date)
                                })
                                $('#submit_security').on('click', function() {
                                    var i = parseInt($('#attempt').val())
                                    var j = parseInt($('#attempt').val()) + 1
                                    $('#attempt').val(i+1)
                                let datetime = new Date()
                                    if(j == 3){
                                        $.ajax({
                                            url: `/members/${name[0]}/${birth_date[0]}/${datetime}/attempt`,
                                            type: 'get',
                                            success: function(response) {
                                                console.log("expired")
                                            }
                                        })
                                    }
                                    let first_question = $('#first_question').find(":selected").text()
                                    let second_question = $('#second_question').val()
                                    let account_codes = []
                                    $.map(response.member, function(member, index) {
                                        account_codes.push(member.account_code)
                                    })
                                    if(($.inArray(second_question, account_codes)) != -1){
                                        $.ajax({
                                            url: `/members/${second_question}/account_code`,
                                            type: 'get',
                                            success: function(response) {
                                                console.log(response)
                                            }
                                        })
                                    }

                                if (first_question == "") {
                                    $('#first_question').parent().removeClass('error')
                                    $('#first').find('.prompt').remove()
                                    $('#first_question').parent().addClass('error')
                                    $('#first').append(`<div class="ui basic red pointing prompt label transition visible">Please select an answer</div>`)
                                    $('p[role="append_security"]').empty()
                                }
                                if (second_question == "") {
                                    $('#second_question').parent().removeClass('error')
                                    $('#second').find('.prompt').remove()
                                    $('#second_question').parent().addClass('error')
                                    $('#second').append(`<div class="ui basic red pointing prompt label transition visible">Please enter an answer</div>`)
                                    $('p[role="append_security"]').empty()
                                }
                                if ((first_question != "" && second_question != "")) {
                                    $('#first_question').parent().removeClass('error')
                                    $('#first').find('.prompt').remove()
                                    $('#second_question').parent().removeClass('error')
                                    $('#second').find('.prompt').remove()
                                    if (($('#first_question').find(":selected").text() == $('#first_answer').val()) && ($('#second_question').val() == $('#second_answer').val())) {
                                        let member_id = $('#member_id2').val()
                                        $.ajax({
                                            url: `/members/${member_id}/send_pin`,
                                            type: 'get',
                                            success: function(response) {
                                                $('#pin_modal').attr('class', 'ui tiny modal');
                                                $('#pin_modal').modal({
                                                    transition: 'fade right'
                                                }).modal('show')
                                            }
                                        })
                                    } else {
                                        $('div[id="message"]').remove()
                                        $('p[role="append_security"]').append(error + '<li>Oops! Wrong Answer Please Try Again!</li> </ul> </div>')
                                    }
                                    $("#first_question").on('keyup', function(e) {
                                        if ($(this).val().length > 0) {
                                            $('#first_question').parent().removeClass('error')
                                            $('#first').find('.prompt').remove()
                                        }
                                    })
                                    $("#second_question").on('keyup', function(e) {
                                        if ($(this).val().length > 0) {
                                            $('#second_question').parent().removeClass('error')
                                            $('#second').find('.prompt').remove()
                                        }
                                    })
                                }
                            })
                            $('#security_modal').attr('class', 'ui tiny modal');
                            $('#security_modal').modal({
                                transition: 'fade right'
                            }).modal('show')
                            jQuery.fn.shuffle = function() {
                                var j;
                                for (var k = 0; k < this.length; k++) {
                                    j = Math.floor(Math.random() * this.length);
                                    $(this[k]).before($(this[j]));
                                }
                                return this;
                            };
                            $('#first_question option.choices').shuffle();
                        }

                        }
                    }
                })
            }
        })
    })

    $('#validate_cvv').on('click', function() {
        let cvv = $('input[name="cvv"]').val()
        let card = $('#card').val()
        let error = '<div id="message_cvv" class="ui negative message"><ul class="list">'
        if (cvv == "") {
            $('div[id="message_cvv"]').remove()
            $('p[role="append_cvv"]').append(error + '<li>Card CVV is required.</li> </ul> </div>')
        } else {
            $.ajax({
                url: `/members/card/${card}/${cvv}`,
                type: 'get',
                success: function(response) {
                    if (response.message == "Card CVV is required") {
                        $('div[id="message_cvv"]').remove()
                        $('p[role="append_cvv"]').append(error + '<li>Card CVV is required.</li> </ul> </div>')
                        $('#cvv').addClass('error')
                    } else if (response.message == "CVV should be 3-digit") {
                        $('div[id="message_cvv"]').remove()
                        $('p[role="append_cvv"]').append(error + '<li>CVV should be 3-digit.</li> </ul> </div>')
                    } else if (response.message == "Card CVV do not match") {
                        $('div[id="message_cvv"]').remove()
                        $('p[role="append_cvv"]').append(error + '<li>Card CVV do not match.</li> </ul> </div>')
                    } else {
                        $('form[id="validate_cvv_form"]').submit()
                    }
                }
            })
        }
    })

    $('#validate_pin').on('click', function() {
        let pin = $('input[name="pin"]').val()
        let link = $('#link2').val()
        let id = $('#member_id2').val()
        let error = '<div id="message_pin" class="ui negative message"><ul class="list">'
        if (pin == "") {
            $('div[id="message_pin"]').remove()
            $('p[role="append_pin"]').append(error + '<li>Pin required.</li> </ul> </div>')
        } else {
            $.ajax({
                url: `/members/pin/${id}/${pin}`,
                type: 'get',
                success: function(response) {
                    if (response.message == "Member Not Found") {
                        $('div[id="message_pin"]').remove()
                        $('p[role="append_pin"]').append(error + '<li>Member Not Found.</li> </ul> </div>')
                        $('#pin').addClass('error')
                    } else if (response.message == "Pin should be 4-digit") {
                        $('div[id="message_pin"]').remove()
                        $('p[role="append_pin"]').append(error + '<li>Pin should be 4-digit.</li> </ul> </div>')
                    } else if (response.message == "Invalid PIN") {
                        $('div[id="message_pin"]').remove()
                        $('p[role="append_pin"]').append(error + '<li>Invalid Pin.</li> </ul> </div>')
                    } else if (response.message == "Pin already expired") {
                        $('div[id="message_pin"]').remove()
                        $('p[role="append_pin"]').append(error + '<li>Pin already expired.</li> </ul> </div>')
                    } else {
                        $('form[id="validate_pin_form"]').submit()
                    }
                }
            })
        }
    })

});

onmount('div[role="request_consult"]', function() {

    $('.search-dropdown').dropdown({ fullTextSearch: true, sortSelect: true, match:'text'});

    $('#filter_specialization').click(function(){
        let f_id = $(this).attr('f_id')
        $('#f_id').val(f_id)
        $('#psf_modal').modal('show')
    })

    let birthdate = moment($('p[id="dob"]').text()).format("YYYY-MM-DD");
    let age = Math.floor(moment().diff(birthdate, 'years', true))
    $('p[id="age"]').text('Age: ' + age);

    $('select[name="loa[consultation_type]"]').on('change', function(){
        $('#submit').removeClass('disabled')
        if($('select[name="loa[consultation_type]"] option:selected').val() == "initial")
        {
          let temp = 'Z71.1 | PERSONS ENCOUNTERING HEALTH SERVICES FOR OTHER COUNSELLING AND MEDICAL ADVICE, NOT ELSEWHERE CLASSIFIED: Person with feared complaint in whom no diagnosis is made'
          let value = $('select[name="loa[diagnosis_id]"] > option:contains("Z71.1")').val()
          let container = $('select#loa_diagnosis_id').closest('div')
          $('select#loa_diagnosis_id').val(value).trigger('change')
          container.find('.ui.basic.red.pointing.prompt.label.transition').removeClass('visible')
          container.find('.ui.basic.red.pointing.prompt.label.transition').addClass('hidden')
          container.removeClass('error')
        }
      })

    $('#consult_form').form({
        inline: true,
        fields: {
            'loa[consultation_type]': {
                identifier: 'loa[consultation_type]',
                rules: [{
                    type: 'empty',
                    prompt: 'Please enter consultation type'
                }, ]
            },
            'loa[doctor_specialization_id]': {
                identifier: 'loa[doctor_specialization_id]',
                rules: [{
                    type: 'empty',
                    prompt: 'Please enter doctor'
                }, ]
            },
            'loa[diagnosis_id]': {
                identifier: 'loa[diagnosis_id]',
                rules: [{
                    type: 'empty',
                    prompt: 'Please enter diagnosis'
                }, ]
            },
        }
    });

    $('#cancel_request').on('click', function() {
        let loa_id = $(this).attr('loa_id')
        swal({
        title: 'Cancel LOA Request?',
        text: `Cancelling this LOA request will automatically delete this request from the system`,
        type: 'question',
        showCancelButton: true,
        confirmButtonText: '<i class="check icon"></i> Yes, Cancel Request',
        cancelButtonText: '<i class="remove icon"></i> No, Keep Request',
        confirmButtonClass: 'ui positive button',
        cancelButtonClass: 'ui negative button',
        buttonsStyling: false,
        reverseButtons: true,
        allowOutsideClick: false

        }).then(function() {
        window.location.replace(`/loas/${loa_id}/cancel_request`);
        })

    })
});

onmount('div[id="psf_modal"]', function(){
    $('#append_specialization').hide()
    $('#filter_submit').on('click', function(){
      let val = $('.ui.radio.checkbox.checked').find('label').text()
      let f_id = $('#f_id').val()
      if(val == "") {
        $('.ajs-message.ajs-error.ajs-visible').remove()
        alertify.error('<i class="close icon"></i><p>Please select a specialization.</p>')
      } else {
        const csrf = $('input[name="_csrf_token"]').val();
        $.ajax({
          url: `/loas/${f_id}/${val}/filter_specializations`,
          headers: {"X-CSRF-TOKEN": csrf},
          type: 'get',
          success: function(response){
            let obj = JSON.parse(response)
            $('#loa_doctor_specialization_id option').remove();

            for(let option of obj){
              let new_row = `<option value="${option.value}">${option.display}</option>`
              $('#loa_doctor_specialization_id').append(new_row)
            }

            $('#loa_doctor_specialization_id').val('').trigger('change')
            $('#loa_doctor_specialization_id').dropdown('clear');
            $('#psf_modal').modal('hide')
          }
        })
        $('#append_specialization').show()
        $('#spec_val').text(val)
      }
    })

    $('#filter_all_specialization').on('click', function(){
        let f_id = $(this).attr('f_id')
        const csrf = $('input[name="_csrf_token"]').val();
        $.ajax({
          url: `/loas/${f_id}/filter_all_specializations`,
          headers: {"X-CSRF-TOKEN": csrf},
          type: 'get',
          success: function(response){
            let obj = JSON.parse(response)
            $('#loa_doctor_specialization_id option').remove();

            for(let option of obj){
              let new_row = `<option value="${option.value}">${option.display}</option>`
              $('#loa_doctor_specialization_id').append(new_row)
            }

            $('#loa_doctor_specialization_id').val('').trigger('change')
            $('#loa_doctor_specialization_id').dropdown('clear');
            $('#psf_modal').modal('hide')
          }
        })
        $('#append_specialization').hide()
    })
  })

onmount('div[role="forgot_password"]', function() {

  $('input[name="session[username]"]').on('keypress', function(evt){
    let theEvent = evt || window.event;
    let key = theEvent.keyCode || theEvent.which;
    key = String.fromCharCode( key );
    let regex = /[``~<>^'{}[\]\\;':"/?!@#$%&*+()=,]/;

    if($(this).val().length <= 1 && evt.keyCode == 32 || regex.test(key)){
      return false;
    }else{
      return true;
    }
  });

  $.fn.form.settings.rules.validateChannel = function(param) {
    if ($('input[name="session[channel]"]:checked').val() == "Email") {
      let email = $('input[name="session[email]"]').val();
      if (email == "") {
        return false;
      } else {
        return true;
      }
    } else {
      let mobile = $('input[name="session[mobile]"]').val();
      if (mobile == "") {
        return false;
      } else {
        return true;
      }
    }
  }

  $.fn.form.settings.rules.validateMobile = function(param) {

    if (param == '') {
      return true;
    } else {

      param = param.replace(/-/g, '');
      if (/^0[0-9]{10}$/.test(param)) {
        return true;
      } else {
        return false;
      }
    }
  }

  $.fn.form.settings.rules.validateEmail = function(param) {

    if (param == '') {
      return true;
    } else {

      if (/^[A-Za-z0-9._,-]+@[A-Za-z0-9._,-]+\.[A-Za-z]{2,4}$/.test(param)) {
        return true;
      } else {
        return false;
      }
    }
  }

  // $('#forgot_password_form').form({
  //   inline: true,
  //   on: 'blur',
  //   fields: {
  //     'session[username]': {
  //       identifier: 'session[username]',
  //       rules: [{
  //         type: 'empty',
  //         prompt: 'Please enter username'
  //       },
  //       {
  //         type: 'minLength[8]',
  //         prompt: 'Please enter at least 8 characters'
  //       },
  //       {
  //         type: 'maxLength[20]',
  //         prompt: 'Please enter at most 20 characters'
  //       },
  //       {
  //         type: 'regExp[/^[0-9ña-zÑA-Z ._-]*$/]',
  //         prompt: 'The username you have entered is invalid'
  //       }]
  //     },
  //     'session[email]': {
  //       identifier: 'session[email]',
  //       rules: [{
  //         type: 'validateChannel[param]',
  //         prompt: 'Please enter registered email address'
  //       },
  //       {
  //         type: 'validateEmail[param]',
  //         prompt: 'The email you have entered is invalid'
  //       }]
  //     },
  //     'session[mobile]': {
  //       identifier: 'session[mobile]',
  //       rules: [{
  //         type: 'validateChannel[param]',
  //         prompt: 'Please enter registered mobile number'
  //       },
  //       {
  //         type: 'validateMobile[param]',
  //         prompt: 'The mobile number you have entered is invalid'
  //       }]
  //     }
  //   },
  // });


  $('#forgot_password_form_v2').form({
    inline: true,
    on: 'blur',
    fields: {
      'session[pnumber_or_email]': {
        identifier: 'session[pnumber_or_email]',
        rules: [{
          type: 'empty',
          prompt: 'Please enter email address or phone number'
        }]
      },
    },
  });

});

onmount('div[role="reset_password"]', function() {
  $('#reset_password_form').form({
    inline: true,
    fields: {
      'user[password]': {
        identifier: 'user[password]',
        rules: [{
          type: 'empty',
          prompt: 'Please enter password'
        },
        {
          type: 'regExp[^(?=.{8,})(?=.*[a-z])(?=.*[A-Z])(?=.*[@#$%^&+=]).*$]',
          prompt: 'Password must be at least 8 characters and should contain alpha-numeric, special-character, atleast 1 capital letter'
        }]
      },
      'user[password_confirmation]': {
        identifier: 'user[password_confirmation]',
        rules: [{
          type: 'empty',
          prompt: 'Please enter confirm password'
        },
        {
          type: 'match[user[password]]',
          prompt: 'Passwords do not match'
        }]
      },
    },
  });

});
