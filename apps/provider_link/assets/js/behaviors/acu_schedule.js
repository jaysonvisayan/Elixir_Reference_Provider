onmount('div[id="acu_schedule_member"]', function() {
  var valArray = []
  $("input:checkbox.selection").each(function () {
    var value = $(this).val();

    if(this.checked) {
      valArray.push(value);
    } else {
      var index = valArray.indexOf(value);

      if (index >= 0) {
        valArray.splice( index, 1)
      }
    }
    $('input[name="acu_schedule_member[acu_schedule_member_ids_main]"]').val(valArray)
    $('#selected_members').html(valArray.length)
  });

  $('input:checkbox.selection').on('change', function() {
    let val = $('input[name="acu_schedule_member[acu_schedule_member_ids_main]"]').val()
    let valArray2 = val.split(",").filter(function(e) { return e != ""; })
    let value = $(this).val()
      
    if (this.checked) {
      valArray2.push(value)
    } else {
      var index = valArray2.indexOf(value)
      if (index >= 0) {
        valArray2.splice(index, 1)
      }
    }
    $('input[name="acu_schedule_member[acu_schedule_member_ids_main]"]').val(valArray2)
    $('#selected_members').html(valArray2.length)   
  })
  
  $('#select_all').on('change', function() {
    valArray.length = 0
    var table = $('#acu_mobile_table').DataTable()
    var rows = table.rows({ 'search': 'applied' }).nodes();
    if ($(this).is(':checked')) {
      $('input[type="checkbox"]', rows).each(function() {
        var value = $(this).val()

        if (this.checked) {
          valArray.push(value)
        } else {
          var index = valArray.indexOf(value);

          if (index >= 0) {
            valArray.splice(index, 1)
          }
          valArray.push(value)
        }
        $(this).prop('checked', true)
      })

    } else {
      valArray.length = 0
      $('input[type="checkbox"]', rows).each(function() {
        $(this).prop('checked', false)
      })
    }
    $('input[name="acu_schedule_member[acu_schedule_member_ids_main]"]').val(valArray)
    $('#selected_members').html(valArray.length)
  })
})

onmount('div[role="fileupload"]', function(){
  $('#addFile').on('click', function(){
    $('#acu_file').trigger('click')
  })
  $('#acu_file').change(function(){
    $('#addFile').text($(this)[0].files[0].name)
  })
})



// onmount('div[id="acu_mobile"]', function() {
//   const csrf = $('input[name="_csrf_token"]').val();
//   let user_ids = []
//   let files

// Array.prototype.delayedForEach = function(callback, timeout, thisArg, done){
//     var i = 0,
//         l = this.length,
//         self = this;

//     var caller = function() {
//         callback.call(thisArg || self, self[i], i, self);
//         if(++i < l) {
//             setTimeout(caller, timeout);
//         } else if(done) {
//             setTimeout(done, timeout);
//         }
//     };

//     caller();
// };


//   $('#acu_schedule_table').find('tbody').find('tr').find('input[type="checkbox"]').on('change', function(){
//       let value = $(this).val()
//       let check = $(this).attr("checked")
//       if($(this).is(":checked")){
//         // $(this).removeAttr("checked")

//         user_ids.push(value)
//       } else {
//         let index = user_ids.indexOf(value);
//         if (index >= 0) {
//            user_ids.splice( index, 1)
//         }
//         // $(this).attr("checked", "checked")
//       }
//     })

//   $('#export_btn').on('click', function(){
//      if (user_ids.length){
//          const file = "sample"
//          $.ajax({
//            url:`/acu_schedule_export`,
//            headers: {"X-CSRF-TOKEN": csrf},
//            type: 'get',
//            data: {ids: user_ids},
//            success: function(response){
//             let link = response.link
//             user_ids.delayedForEach(function(value){
//               let true_link = `${link}acu_schedules/${value}/export`
//               window.location.assign(true_link)
//             }, 2000, null, function() {
//               // delete_xlsx()
//             })
//            }
//          })
//      }
//     else{
//          swal({
//       title: 'Please select batch first',
//       type: 'error',
//       allowOutsideClick: false,
//       confirmButtonText: '<i class="check icon"></i> Ok',
//       confirmButtonClass: 'ui button primary',
//       buttonsStyling: false
//     }).then(function () {
//     }).catch(swal.noop)
//     }
//   })

//   const delete_xlsx = () => {
//          $.ajax({
//            url:`/acu_schedules/delete/xlsx`,
//            headers: {"X-CSRF-TOKEN": csrf},
//            type: 'get',
//            data: {files: files},
//          })
//   }
//  // FOR CHECK ALL
//   $('#checkAllacu').on('change', function(){
//     var table = $('#acu_schedule_table').DataTable()
//     var rows = table.rows({ 'search': 'applied' }).nodes();

//     if ($(this).is(':checked')) {

//     user_ids = []
//       $('input[type="checkbox"]', rows).each(function() {
//         var value = $(this).val()

//         if (this.checked) {
//           user_ids.push(value)
//         } else {
//           var index = user_ids.indexOf(value);

//           if (index >= 0) {
//             user_ids.splice(index, 1)
//           }
//           user_ids.push(value)
//         }
//         $(this).prop('checked', true)
//       })
//     }
//  else {

//       user_ids.length = 0
//       $('input[id="acu_sched_ids"]').each(function() {
//         $(this).prop('checked', false)
//       })
//     }
//   })
// })

$('#confirm_acu').click((e) => {
  swal({
    title: 'Are you sure the schedule is correct and final?',
    type: 'warning',
    showCancelButton: true,
    cancelButtonText: 'No',
    confirmButtonColor: '#3085d6',
    cancelButtonColor: '#d33',
    confirmButtonText: 'Yes'
  }).then((result) => {
    // console.log(123)
    if (result) {
      // swal(
      //   'Submitted!',
      //   'Your file has been submitted.',
      //   'success'
      // )

      $('#submit_upload').submit()
    }
  })
})


onmount('#show_batch_prompt', function(){
  swal({
    title: 'You will receive an email confirmation after the batch is available for viewing at paylink',
    type: 'info',
    // showCancelButton: true,
    // cancelButtonText: 'No',
    confirmButtonColor: '#3085d6',
    // cancelButtonColor: '#d33',
    confirmButtonText: 'Okay'
  }).then((result) => {
    if (result) {
      window.location.assign("/acu_schedules")
    }
  })
})

  $('.submit_upload').on('click', function() {
    let soa = $('#acu_schedule_upload_soa_reference_no').val()
    let check_doc = $('#acu_file').val() == ""
    let check_soa = $('#acu_schedule_upload_soa_reference_no').val() == ""
    // let check_stale = $('#stale').val() == "true"

    if(check_soa) {
      $('#soa_field').removeClass('error')
      $('#soa_field').find('.prompt').remove()
      $('.ajs-message.ajs-error.ajs-visible').remove()
      $('#soa_field').addClass('error')
      $('#soa_field').append(`<div class="ui basic red pointing prompt label transition visible">Please enter soa reference no.</div>`)
    }
    else {
      if (/^[a-zA-Z0-9._-]+$/.test(soa) == false){
        $('#soa_field').append(`<div class="ui basic red pointing prompt label transition visible">Must consist of letters, numbers, dot (.) underscore (_) and hypen (-) only</div>`)
      }
      else if (check_doc) {
        $('#soa_field').removeClass('error')
        $('#soa_field').find('.prompt').remove()
        $('.ajs-message.ajs-error.ajs-visible').remove()
        alertify.error('<i class="close icon"></i>Please Upload Soa.')
      }
      else {
        // if(check_stale) {
        //   $('#soa_field').removeClass('error')
        //   $('#soa_field').find('.prompt').remove()
        //   $('.ajs-message.ajs-error.ajs-visible').remove()
        //   swal({
        //     title: 'The batch cannot be submitted, the claims are staled.',
        //     type: 'error',
        //     allowOutsideClick: false,
        //     confirmButtonText: '<i class="check icon"></i> Ok',
        //     confirmButtonClass: 'ui button primary',
        //     buttonsStyling: false
        //   }).then(function() {}).catch(swal.noop)
        // }
        // else {
          $('#confirm_acu_schedule').modal('show')
        // }
      }
    }
  })

  $('#acu_schedule_upload_soa_reference_no').on('keyup', function(){
    $('#soa_field').removeClass('error')
    $('#soa_field').find('.prompt').remove()
  })

  $('#acu_schedule_verify_confirm_cancel').on('click', function(){
    $('#confirm_acu_schedule').modal('hide')
  })

  var eta = new Inputmask("decimal", {
    allowMinus:false,
    min: 1,
    radixPoint: ".",
    groupSeparator: ",",
    digits: 2,
    autoGroup: true,
    // prefix: '₱ ',
    rightAlign: false
  });
  eta.mask($('#estimate_total_amount'))

  // $.fn.form.settings.rules.checkEstimatedAmount = function(param) {
  //   if (parseInt($('#guaranteed_amount').val()) > parseInt(param) || parseInt(param) == 0) {
  //     return true
  //   } else {
  //     return false
  //   }
  // }

  $('#acu_schedule_verify_confirm_submit').on('click', function(){
    $('#acu_schedule_upload_form').submit()
  })

onmount('#cancel_acu_schedule_loa', function(){
  $(this).on('click', function(){
    $('#cancel_upload').submit()
  })
})

