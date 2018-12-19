onmount('div[role="multipleFileUpload"]', function () {
  let counter = 1
  let delete_array = []

  $('#addFile').on('click', function(){
    let file_id = '#file_' + counter
    $('#filePreviewContainer').append(`<input type="file" class="hide" id="file_${counter}" name="loa[files][]">`)
    $(file_id).on('change', function(){
      let icon = ''
      let file_type = $(file_id)[0].files[0].type
      if (file_type.includes('ms-excel')) {
        icon = 'file excel outline'
      } else if (file_type.includes('pdf')) {
        icon = 'file pdf outline'
      } else {
        icon = 'file outline'
      }
      if ($(this).val() != '') {
        let file_size = $(file_id)[0].files[0].size
        if(file_type == "image/jpeg" || file_type == "image/png" || file_type == "application/pdf") {
          if(file_size <= 5242880) {
            let file_name = $(file_id)[0].files[0].name
            let new_row =
              `\
              <div class="ui grid">\
                <div class="row">\
                  <div class="two wide column field">\
                    <i class="big ${icon} icon"></i>\
                  </div>\
                  <div class="six wide column field">\
                    <div class="content">\
                      ${file_name}\
                    </div>\
                  </div>\
                  <div class="eight wide column field">\
                    <div class="right floated content">\
                      <button class="small ui button remove-file right floated" style="margin-top:0" fileID="${file_id}" type="button">Remove</button>\
                    </div>\
                  </div>\
                </div>\
              </div>\
              `
            $('#filePreviewContainer').append(new_row)
          } else {
            $(file_id).remove()
            alertify.error('<i class="close icon"></i>File size has reached 5MB limit.')
          }

        } else {
          $(file_id).remove()
          alertify.error('<i class="close icon"></i>Invalid file format.')
        }
      }
    })
    $(file_id).click()
    counter++
  })

  $('body').on('click', '.remove-file', function() {
    let file_id = $(this).attr('fileID')
    $(file_id).remove()
    $(this).closest('.ui.grid').remove()
  });

  $('body').on('click', '.remove-uploaded', function() {
    let file_id = $(this).attr('fileID')
    $(this).closest('.item').remove()
    if (delete_array.includes(file_id) == false) {
      delete_array.push(file_id)
    }
    $('#deleteIDs').val(delete_array)
  });

  $('input[name="loa[discharge_date]"]').on('focusout', function () {
    $('#verify_loa').form('validate form')
    let value = $(this).val()
    let loa_id = $('input[name="loa[loa_id]"]').val()
    const csrf = $('input[name="_csrf_token"]').val();
    $.ajax({
      url: `/loas/save_discharge_date`,
      headers: {"x-csrf-token": csrf},
      type: 'post',
      data: {discharge_date: value, loa_id: loa_id}
    })
  })

  $.fn.form.settings.rules.GreaterThanAdmissionDate = function (param) {
    let admission_date = $('input[name="loa[admission_date]"]').val()
    let discharge_date = $('input[name="loa[discharge_date]"]').val()

    if (admission_date <= discharge_date) {
      return true
    } else {
      $('#confirmation_vloa_modal').modal('hide')
      return false
    }
  }

  $.fn.form.settings.rules.isDateEmptyDate = function (param) {
    if (param != "") {
      return true
    } else {
      $('#confirmation_vloa_modal').modal('hide')
      return false
    }
  }

  $('#verify_loa').form({
    inline: true,
    on: 'blur',
    fields: {
      'loa[admission_date]': {
        identifier: 'loa[admission_date]',
        rules: [{
          type: 'isDateEmptyDate[param]',
          prompt: 'Please enter Admission Date'
        },]
      },
      'loa[discharge_date]': {
        identifier: 'loa[discharge_date]',
        rules: [{
          type: 'isDateEmptyDate[param]',
          prompt: 'Please enter Discharge Date'
        },
        {
          type: 'GreaterThanAdmissionDate[param]',
          prompt: 'Discharge Date must be greater than or equal to the Admission Date'
        }
        ]
      }
    }
  })

  $('#verify_loa_btn').on('click', function() {
    let result = $('#verify_loa').form('validate form')
    $('input[name="loa[soa_reference_no]"]').closest('.field').removeClass('error')
    $('input[name="loa[soa_reference_no]"]').closest('.field').find('.prompt').remove()
    if(result){
      let soa = $('input[name="loa[soa_reference_no]"]').val()
      if (soa == ""){
        $('input[name="loa[soa_reference_no]"]').closest('.field').addClass('error')
        $('input[name="loa[soa_reference_no]"]').closest('.field').append(`<div class="ui basic red pointing prompt label transition visible">Please enter Soa Reference No</div>`)
      }
      else{
        $('input[name="loa[soa_reference_no]"]').closest('.field').removeClass('error')
        $('input[name="loa[soa_reference_no]"]').closest('.field').find('.prompt').remove()
        $('#confirmation_vloa_modal').modal('show')
      }
    }else{
      let soa = $('input[name="loa[soa_reference_no]"]').val()
      if (soa == ""){
        $('input[name="loa[soa_reference_no]"]').closest('.field').addClass('error')
        $('input[name="loa[soa_reference_no]"]').closest('.field').append(`<div class="ui basic red pointing prompt label transition visible">Please enter Soa Reference No</div>`)
      }
      else{
        $('input[name="loa[soa_reference_no]"]').closest('.field').removeClass('error')
        $('input[name="loa[soa_reference_no]"]').closest('.field').find('.prompt').remove()
      }
    }
  })



  $('#loa_verify_confirm_no').on('click', function(){
    $('#confirmation_vloa_modal').modal('hide')
  })

  $('#loa_verify_confirm_yes').on('click', function(){
    $('#verify_loa').submit()
  })

  $('#request_loa_btn').on('click', function() {
    $('#acu_select_package').closest('.dropdown').removeClass('error')
    $('#acu_select_package').closest('.field').find('.prompt').remove()
      let selected_package = $('#acu_select_package').find(":selected").val()
      if (selected_package == ""){
        $('#acu_select_package').closest('.dropdown').addClass('error')
        $('#acu_select_package').closest('.field').append(`<div class="ui basic red pointing prompt label transition visible">Please select Package</div>`)
      }else{
        $('#acu_select_package').closest('.dropdown').removeClass('error')
        $('#acu_select_package').closest('.field').find('.prompt').remove()
        $('#verify_loa').submit()
      }
  })
});
