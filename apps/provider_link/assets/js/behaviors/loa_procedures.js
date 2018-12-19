
            $('#form_lab')
                .form({
                    on: blur,
                    inline: true,
                    fields: {
                        'lab[consultation_date]': {
                            identifier: 'lab[consultation_date]',
                            rules: [{
                                    type: 'empty',
                                    prompt: 'Consultation Date is required'
                                }
                            ]
                        },
                        'lab[doctor_id]': {
                            identifier: 'lab[doctor_id]',
                            rules: [{
                                    type: 'empty',
                                    prompt: 'Ordering Physician is required'
                                }
                            ]
                        },
                    },
                    onSuccess: function(event) {
                      $('#form_lab').submit()
                    }
                });
  $('#empty_diagnosis').on('click', function() {
      $('div[id="message_lab"]').remove()
      $('p#no_diagnosis').append('<div id="message_lab" class="ui negative message"> <div class="header">There were some errors with your submission </div> <ul class="list"><li>Please add at least one diagnosis.</li> </ul> </div>')
})

onmount('button[id="append_procedure"]', function() {

  $("#unit").on('keyup', function (e) {
    if ($(this).val().length > 0) {
        $('#unit_field').removeClass('error')
        $('#unit_field').find('.prompt').remove()
    }
  })
  $("#amount").on('keyup', function (e) {
    if ($(this).val().length > 0) {
        $('#amount_field').removeClass('error')
        $('#amount_field').find('.prompt').remove()
    }
  })
  $("#procedures").on('change', function (e) {
    if ($(this).val().length > 0) {
        $('#procedure_field').removeClass('error')
        $('#procedure_field').find('.prompt').remove()
    }
  })

  $(this).on('click', function() {
    let procedures = $('#procedures').val()
    let unit = $('#unit').val()
    let amount = $('#amount').val()

    $('#unit_field').removeClass('error')
    $('#unit_field').find('.prompt').remove()
    $('#amount_field').removeClass('error')
    $('#amount_field').find('.prompt').remove()
    $('#procedure_field').removeClass('error')
    $('#procedure_field').find('.prompt').remove()
    if((amount == "") || (unit == "") || (procedures == "")) {
      if(unit == "") {
          $('#unit_field').addClass('error')
          $('#unit_field').append(`<div class="ui basic red pointing prompt label transition visible">Please enter unit</div>`)
      }
      if(amount == "") {
          $('#amount_field').addClass('error')
          $('#amount_field').append(`<div class="ui basic red pointing prompt label transition visible">Please enter amount</div>`)
      }
      if(procedures == "") {
          $('#procedure_field').addClass('error')
          $('#procedure_field').append(`<div class="ui basic red pointing prompt label transition visible">Please select a procedure</div>`)
      }
    }
    else
    {
      $('div[id="message"]').remove()
      let number = $('#number').val()
      $("#number").val(parseInt(number) + 1)
      let procedure_select = $('#procedure_select').clone()
      let i = $("#number").val()
      $('div#append').append(procedure_select)

      $('div#append').find('div#procedure_select').attr('id', 'procedure[' + i + ']').attr('number', i)
      $('div#append').find('select[role="procedures"]').attr('id', 'procedure_select[' + i + '][procedure_id]').attr('name', 'procedure[' + i + '][procedure_id]')
      $('div#append').find('div.dropdown.procedure').addClass('disabled')
      let select_value = $('#procedures').dropdown('get value')
      $('select[name="procedure[' + i + '][procedure_id]"]').dropdown('set value', select_value)
      let appended = $('select[name="procedure[' + i + '][procedure_id]"]').val()
      $('#procedure').find('.active.selected').remove()
      $('div#append').find('select[role="procedures"]').removeAttr('role')

      $('div#append').find('input[role="unit"]').attr('id', 'procedure_select[' + i + '][unit]').attr('name', 'procedure[' + i + '][unit]').addClass('validate_required')
      $('div#append').find('input[role="unit"]').removeAttr('role')

      $('div#append').find('input[role="amount"]').attr('id', 'procedure_select[' + i + '][amount]').attr('name', 'procedure[' + i + '][amount]').addClass('validate_required')
      $('div#append').find('input[role="amount"]').removeAttr('role')

      $('#procedure_select').find('input#unit').val('')
      $('#procedure_select').find('input#amount').val('')
      $('select[name="procedure[' + i + '][procedure_id]"]').dropdown('set value', select_value)
      $('#procedures').dropdown('clear')
      $('.dropdown').dropdown()
      $('#append').find('#add_label').hide()
      $('div#append').find('#append_procedure').html('<i class="trash icon"></i>')
      $('div#append').find('#append_procedure').removeClass('basic')
      $('div#append').find('#append_procedure').addClass('red')
      $('div#append').find('#append_procedure').attr('id', 'delete[' + i + ']')

      $('body').on('click', 'button[id="delete[' + i + ']"]', function() {
          $('div#append').find('div[number=' + i + ']').find('div.dropdown.procedure').remove()
          $('div#append').find('div[number=' + i + ']').remove()

          let text = $('div#append').find('div[number=' + i + ']').find('.active.selected').val()
          $('#procedures').append($('<option>', {
              value: text,
              text: text
          }))

      })
    }
    })
  $('#submit').on('click', function() {
    let input_checker = true
    if (validate_text_inputs() == false) {
      input_checker = false
    }
      function validate_text_inputs() {
        let valid = true
        $('.validate_required').each(function(){
          $(this).on('keyup', function (e) {
            if ($(this).val().length > 0) {
                    $(this).closest('div').removeClass('error')
                    $(this).closest('div').find('.prompt').remove()
            }
          })
          $(this).closest('div').removeClass('error')
          $(this).closest('div').find('.prompt').remove()
          let field = $(this).val()
          if (field == "") {
            let field_name = $(this).closest('div').find('label').html().toLowerCase()
            console.log(field_name)
            $(this).closest('div').addClass('error')
            $(this).closest('div').append(`<div class="ui basic red pointing prompt label transition visible">Please enter ${field_name}</div>`)
            valid = false
          }
        })
        return valid
      }

  let diagnosis = $('#diagnosis').val()
  if(diagnosis == "") {
      $('#diagnosis_field').removeClass('error')
      $('#diagnosis_field').find('.prompt').remove()
      $('#diagnosis_field').addClass('error')
      $('#diagnosis_field').append(`<div class="ui basic red pointing prompt label transition visible">Please select a diagnosis</div>`)
  }
  else if(input_checker == true){
    if($('div#append').html().length == 0) {
      $('div[id="message"]').remove()
      $('p#no_procedure').append('<div id="message" class="ui negative message"> <div class="header">There were some errors with your submission </div> <ul class="list"><li>Please add at least one procedure.</li> </ul> </div>')
    }
    else {
      $('#submit').removeAttr('type')
    }
  }
  $("#diagnosis").on('keyup', function (e) {
    if ($(this).val().length > 0) {
        $('#diagnosis_field').removeClass('error')
        $('#diagnosis_field').find('.prompt').remove()
    }
  })

  })
})