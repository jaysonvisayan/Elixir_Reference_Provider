onmount('div[id="card_no_cvv_verify"]', function(){
  let Inputmask = require('inputmask')
  let cvvFormat = new Inputmask("numeric", {
    allowMinus:false,
    rightAlign: false
  })

  cvvFormat.mask($('.cvv'))

  $('#btn_card_no_cvv_verify').on('click', function(){
    let cardno1 = $('input[name="for_otp_cardno1"]').val()
    let cardno2 = $('input[name="for_otp_cardno2"]').val()
    let cardno3 = $('input[name="for_otp_cardno3"]').val()
    let cardno4 = $('input[name="for_otp_cardno4"]').val()
    $('#card').val(cardno1 + cardno2 + cardno3 + cardno4)

    let card = $('#card').val()
    let loa_id = $('#loa_id').val()
    let cvv = $('input[name="for_otp_cvv"]').val()
    let error = '<div id="message" class="ui negative message"><ul class="list">'

    if ($('#card').val() == "") {
      $('div[id="message"]').remove()
      $('p[role="append"]').append(error + '<li>Card number is required.</li> </ul> </div>')
    } else {

      $.ajax({
        url: `/members/card/${card}/${cvv}/${loa_id}/for_otp_verification`,
        type: 'get',
        success: function(response) {
          console.log(response)
          if (response.member == undefined) {
            $('div[id="message"]').remove()
            $('p[role="append"]').append(error + '<li>' + response.message + '</li> </ul> </div>')
          } else {

            $('div[id="message"]').remove()
            $('#modal_card_no_eligibility').modal({
              transition: 'fade right'
            }).modal('hide');

            let member_id = response.member.id
            window.document.location = `/loas/${loa_id}/show_verified`

          }

        }
      })
    }


  })



})

