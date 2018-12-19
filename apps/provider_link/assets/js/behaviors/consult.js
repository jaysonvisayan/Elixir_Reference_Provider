onmount('a[id="open_consult"]', function(){
  $('#open_consult').on('click', function(){

    $('#coverage').val('OP Consult');
    $('div[id="choose_option_voucher"]').hide();
    $('input[name="acu_cardno1"]').val('')
    $('input[name="acu_cardno2"]').val('')
    $('input[name="acu_cardno3"]').val('')
    $('input[name="acu_cardno4"]').val('')
    $('input[name="bdate_for_card"]').val('')

    // $('div[id="modal_card_no_eligibility"]')
    // .modal({closable: false,
    //        autofocus: false,
    //        observeChanges: true,
    //          onShow: function(){
    //            $('#birthdate_picker_for_card').calendar({
    //              type: 'date',
    //              popupOptions: {
    //                position: 'right center',
    //                prefer: 'opposite',
    //                hideOnScroll: false
    //              },
    //              inline: false,
    //              formatter: {
    //                date: function(date, settings) {
    //                  if (!date) return '';
    //                  var day = date.getDate() + '';
    //                  if (day.length < 2) {
    //                    day = '0' + day;
    //                  }
    //                  var month = (date.getMonth() + 1) + '';
    //                  if (month.length < 2) {
    //                    month = '0' + month;
    //                  }
    //                  var year = date.getFullYear();
    //                  return year + '-' + month + '-' + day;
    //                }
    //              }
    //            });
    //           }
// })
    //        .modal('show');
  });
})
