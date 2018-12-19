onmount('div[id="new_batch"]', function() {
    let type = $('#type').val()
    $('body').on('click', '#create_batch', function() {
        if (type == "practitioner") {
            $('.ui .form')
                .form({
                    on: 'blur',
                    inline: true,
                    fields: {
                        'batch[doctor_id]': {
                            identifier: 'batch[doctor_id]',
                            rules: [{
                                type: 'empty',
                                prompt: 'Please select practitioner'
                            }]
                        },
                        'batch[soa_reference_no]': {
                            identifier: 'batch[soa_reference_no]',
                            rules: [{
                                    type: 'empty',
                                    prompt: 'Please enter SOA Ref. No.'
                                },
                                {
                                    type: 'regExp',
                                    value: '^[a-zA-Z0-9() . _ -]+$',
                                    prompt: 'Only alphanumeric and (. _ -) characters are allowed'
                                }
                            ]
                        },
                        'batch[soa_amount]': {
                            identifier: 'batch[soa_amount]',
                            rules: [{
                                    type: 'empty',
                                    prompt: 'Please enter estimated amount'
                                },
                                {
                                    type: 'regExp',
                                    value: '^[0-9 .]+$',
                                    prompt: 'Only numeric characters are allowed'
                                }
                            ]
                        },
                        'batch[remarks]': {
                            identifier: 'batch[remarks]',
                            optional: 'true',
                            rules: [{
                                type: 'regExp',
                                value: '^[-:a-zA-Z0-9() \n ]+$',
                                prompt: 'Only alphanumeric characters are allowed'
                            },
                            {
                              type   : 'maxLength[255]',
                              prompt : 'Please enter at most {ruleValue} characters'
                            }]
                        }
                    },
                    onSuccess: function(event, fields) {
                        event.preventDefault()
                        swal({
                            title: "Are you sure you want to create batch?",
                            type: 'question',
                            showCancelButton: true,
                            confirmButtonText: '<i class="send icon"></i> Yes ',
                            cancelButtonText: '<i class="remove icon"></i> No ',
                            confirmButtonClass: 'ui small positive floated button',
                            cancelButtonClass: 'ui small negative floated button',
                            buttonsStyling: false,
                            reverseButtons: true
                        }).then(function() {
                            $('#create_batch_form').unbind();
                            $('#create_batch_form').submit()
                        })

                    }
                })
            $('#create_batch_form').submit()
        } else {
            $('.ui .form')
                .form({
                    on: 'blur',
                    inline: true,
                    fields: {
                        'batch[soa_reference_no]': {
                            identifier: 'batch[soa_reference_no]',
                            rules: [{
                                    type: 'empty',
                                    prompt: 'Please enter SOA Ref. No.'
                                },
                                {
                                    type: 'regExp',
                                    value: '^[a-zA-Z0-9() . _ -]+$',
                                    prompt: 'Only alphanumeric and (. , -) characters are allowed'
                                }
                            ]
                        },
                        'batch[soa_amount]': {
                            identifier: 'batch[soa_amount]',
                            rules: [{
                                    type: 'empty',
                                    prompt: 'Please enter estimated amount'
                                },
                                {
                                    type: 'regExp',
                                    value: '^[0-9 .]+$',
                                    prompt: 'Only numeric characters are allowed'
                                }
                            ]
                        },
                        'batch[remarks]': {
                            identifier: 'batch[remarks]',
                            optional: 'true',
                            rules: [{
                                type: 'regExp',
                                value: '^[-:a-zA-Z0-9() \n ]+$',
                                prompt: 'Only alphanumeric characters are allowed'
                            },
                            {
                              type   : 'maxLength[255]',
                              prompt : 'Please enter at most {ruleValue} characters'
                            }]
                        }
                    },
                    onSuccess: function(event, fields) {
                        event.preventDefault()
                        swal({
                            title: "Are you sure you want to create batch?",
                            type: 'question',
                            showCancelButton: true,
                            confirmButtonText: '<i class="send icon"></i> Yes ',
                            cancelButtonText: '<i class="remove icon"></i> No ',
                            confirmButtonClass: 'ui small positive floated button',
                            cancelButtonClass: 'ui small negative floated button',
                            buttonsStyling: false,
                            reverseButtons: true
                        }).then(function() {
                            $('#create_batch_form').unbind();
                            $('#create_batch_form').submit()
                        })
                    }
                })
                $('#create_batch_form').submit()
        }


    })
})

onmount('div[id="batch_details"]', function() {
    $('#delete_batch').click(function() {
        let batch_id = $(this).attr('batch_id')
        swal({
            title: "Delete Batch?",
            text: "Deleting this Batch will permanently remove it from the system",
            type: 'question',
            showCancelButton: true,
            confirmButtonText: '<i class="send icon"></i> Yes, Delete Batch',
            cancelButtonText: '<i class="remove icon"></i> No, Keep Batch',
            confirmButtonClass: 'ui small positive floated button',
            cancelButtonClass: 'ui small negative floated button',
            buttonsStyling: false,
            reverseButtons: true
        }).then(function() {
            window.location.href = `/batch/${batch_id}/delete_batch`
        })
    });

    $('.loa_delete').on('click', function() {
        let batch_id = $(this).attr('batch_id')
        let loa_id = $(this).attr('loa_id')
        swal({
        title: "Delete LOA?",
        text: "Are you sure you want to remove the LOA from the batch?",
        type: 'question',
        showCancelButton: true,
        confirmButtonText: '<i class="send icon"></i> Yes, Delete Batch',
        cancelButtonText: '<i class="remove icon"></i> No, Keep Batch',
        confirmButtonClass: 'ui small positive floated button',
        cancelButtonClass: 'ui small negative floated button',
        buttonsStyling: false,
        reverseButtons: true
        }).then(function() {
            window.location.href = `/batch/${batch_id}/remove_to_batch/${loa_id}`
        })
    })

  $('body').on('click', '#submit_batch', function() {
    if($('#has_loa').val() == "yes"){
      let batch_id = $('#batch_id').val()
      swal({
          title: "Submit Batch?",
          type: 'question',
          showCancelButton: true,
          confirmButtonText: '<i class="send icon"></i> Yes ',
          cancelButtonText: '<i class="remove icon"></i> No ',
          confirmButtonClass: 'ui small positive floated button',
          cancelButtonClass: 'ui small negative floated button',
          buttonsStyling: false,
          reverseButtons: true
      }).then(function() {
          window.location.href = `/batch/${batch_id}/submit`
      })
    }
    else{
      swal({
        title: 'Please add claim first',
        type: 'warning',
        confirmButtonText: '<i class="check icon"></i> Ok',
        confirmButtonClass: 'ui button',
        buttonsStyling: false,
        reverseButtons: true,
        allowOutsideClick: false
      }).catch(swal.noop)
    }
  })

    // $('#edit_soa').on('click', function() {
    //     let batch_id = $('#batch_id').val()
    //     swal({
    //         allowOutsideClick: false,
    //         allowEnterKey: false,
    //         allowEscapeKey: false,
    //         title: 'Add Edited SOA Amount',
    //         input: 'text',
    //         showCancelButton: false,
    //         confirmButtonText: 'Add',
    //         confirmButtonClass: 'ui blue right floated small button',
    //         cancelButtonText: '<i class="remove icon"></i> No, Keep Batch',
    //         showCloseButton: true,
    //         preConfirm: (value) => {
    //             return new Promise((resolve) => {
    //                 if (value == "") {
    //                     swal.showValidationError('Please enter an amount')
    //                     $('.swal2-confirm.swal2-styled').prop('disabled', false)
    //                     $('.swal2-cancel.swal2-styled').prop('disabled', false)
    //                 } else if (value.split(".").length > 2) {
    //                     swal.showValidationError('Invalid amount. Please enter only one (.)')
    //                     $('.swal2-confirm.swal2-styled').prop('disabled', false)
    //                     $('.swal2-cancel.swal2-styled').prop('disabled', false)
    //                 } else if (/^[0-9 .]+$/.test(value) == false) {
    //                     swal.showValidationError('Please enter numeric values only')
    //                     $('.swal2-confirm.swal2-styled').prop('disabled', false)
    //                     $('.swal2-cancel.swal2-styled').prop('disabled', false)
    //                 } else {
    //                     window.location.href = `/batch/${batch_id}/edit_soa/${value}`
    //                     resolve()
    //                 }
    //             })
    //         },
    //     }).then((result) => {
    //         window.location.href = `/batch/${batch_id}/edit_soa/${result}`
    //     })
    // })
})

onmount('div[id="batch"]', function() {
    let type = $('#type')
    $('#pf').click(function() {
        $('div[id="message"]').remove()
        type.val('pf')
        $('.card').removeAttr("style")
        $(this).css("background-color", "#00DDFB");
    })
    $('#hb').click(function() {
        $('div[id="message"]').remove()
        type.val('hb')
        $('.card').removeAttr("style")
        $(this).css("background-color", "#00DDFB");
    })
    $('#proceed_button').click(function() {
        if (type.val() == "hb") {
            window.location.href = `/batch/new?type=hospital_bill`
        } else if (type.val() == "pf") {
            window.location.href = `/batch/new?type=practitioner`
        } else {
            $('div[id="message"]').remove()
            $('p#proceed').append('<div id="message" class="ui negative message"><ul class="list"><li>Please select atleast one type.</li> </ul> </div>')
        }
    })
    $('#new_batch').click(function() {
        $('#modal_new_batch').modal({
            closable: false,
            autofocus: false,
            observeChanges: true
        }).modal('show')
    })
})
