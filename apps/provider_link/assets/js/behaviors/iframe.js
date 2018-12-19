onmount('div[id="iframe"]', function(){
    $('#coverage').val('ACU');
    $('div[id="choose_option_voucher"]').show();
      $('div[id="modal_iframe"]')
      .modal({closable: false,
             autofocus: false,
             observeChanges: true,
             onShow: function(){
               $('#birthdate_picker_for_card_acu').calendar({
                 type: 'date',
                 popupOptions: {
                   position: 'right center',
                   prefer: 'opposite',
                   hideOnScroll: false
                 },
                 inline: false,
                 formatter: {
                   date: function(date, settings) {
                     if (!date) return '';
                     var day = date.getDate() + '';
                     if (day.length < 2) {
                       day = '0' + day;
                     }
                     var month = (date.getMonth() + 1) + '';
                     if (month.length < 2) {
                       month = '0' + month;
                     }
                     var year = date.getFullYear();
                     return year + '-' + month + '-' + day;
                   }
                 }
               })
             }
      })
      .modal('show');

  let Inputmask = require('inputmask')
  let cvvFormat = new Inputmask("numeric", {
    allowMinus:false,
    rightAlign: false
  })

  cvvFormat.mask($('#cvv_index'))

  $('#iframe_verify').on('click', function(e) {
    let paylink_user_id = $('#paylink_user_id').val()
    let coverage = "ACU"
    let card = $('#card').val()
    // let cvv = $('input[name="cvv_index"]').val()
    let bdate = $('input[name="bdate_for_card"]').val()
    let error = '<div id="message" class="ui negative message"><ul class="list">'
      $.ajax({
        url: `/members/eligibility/card/${paylink_user_id}/${card}/with_loa_validation/${bdate}/${coverage}`,
        type: 'get',
        success: function(response) {
          if (response.member == undefined) {
            $('div[id="message"]').remove()
            $('p[role="append"]').append(error + '<li>' + response.message + '</li> </ul> </div>')
          } else {

            $('div[id="message"]').remove()
            $('#modal_card_no_eligibility').modal({
              transition: 'fade right'
            }).modal('hide');

            let member_id = response.member.id
            window.document.location = `/members/eligibility/${paylink_user_id}/${response.member.card_number}/${response.member.id}/card_no_bdate`

          }

        }
      })
  })      
})