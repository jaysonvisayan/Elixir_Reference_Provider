onmount('div[role="login_user"]', function() {
    $('form[action="/sign_in"]').on('submit', function(e) {
        const username = $('input[name="session[username]"]').val()
        const password = $('input[name="session[password]"]').val()
        $('div[id="message"]').remove()

        if (username == "" && password == "") {
            $('p[role="append"]').append('<div id="message" class="ui negative message userpass">Please enter your username and password</div>')
            $('#username').addClass('error')
            $('#password').addClass('error')

            $('#username').on('keyup', function() {
              if ($(this).find('input').val() != "") {
                  $('#username').removeClass('error')

                if ($('#password').find('input').val() != "") {
                  $('div[id="message"]').remove()
                }

              }
            })

            $('#password').on('keyup', function() {
              if ($(this).find('input').val() != "") {
                  $('#password').removeClass('error')

                if ($('#username').find('input').val() != "") {
                  $('div[id="message"]').remove()
                }

              }
            })
            e.preventDefault()
        } else if (username == "") {
            $('p[role="append"]').append('<div id="message" class="ui negative message user">Please enter your username</div>')
            $('#username').addClass('error')
            e.preventDefault()
        } else if (password == "") {
            $('p[role="append"]').append('<div id="message" class="ui negative message pass">Please enter your password</div>')
            $('#password').addClass('error')
            e.preventDefault()
        }else if ($("#g-recaptcha-response").val() == "") {
          $('div[id="message"]').remove()
          $('p[role="append"]').append('<div id="message" class="ui negative message pass">Please enter reCAPTCHA</div>')
          e.preventDefault()
        }
    });

     $("#eye").click(function() {
        var input = $('input[name="session[password]"]')
        if (input.attr("type") == "password") {
            input.attr("type", "text")
        } else {
            input.attr("type", "password")
        }
    })

    $('#session_password').keypress(function(e) {
      var s = String.fromCharCode( e.which );
      if ((s.toUpperCase() === s && s.toLowerCase() !== s && !e.shiftKey) || (s.toUpperCase() !== s && s.toLowerCase() === s && e.shiftKey)) {
        $('.userpass').remove()
        $('div[id="message"]').remove()
        $('p[role="append"]').append('<div id="message" class="ui negative message pass">WARNING: Caps Lock is on.</div>')
        $('#password').addClass('error')
      } else if ((s.toLowerCase() === s && s.toUpperCase() !== s && !e.shiftKey)|| (s.toLowerCase() !== s && s.toUpperCase() === s && e.shiftKey)) {
          $('#password').removeClass('error')
          $('div[id="message"]').remove()
      }
    })
})