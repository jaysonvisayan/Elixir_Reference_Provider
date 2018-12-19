onmount('a[id="open_acu"]', function() {
    $('#open_acu').on('click', function() {
        $('#coverage').val('ACU');
        $('div[id="choose_option_card"]').show();
        $("#modal_options").modal("show")
    });

    $('#verify').on('click', function() {
        $('div[id="message"]').remove()
        let full_name = $('#full_name').val()
        let birth_date = $('#birth_date').val()
        let coverage = $('#coverage').val()
        let error = '<div id="message" class="ui negative message"><ul class="list"><li>'
        $('input[name="photo_params[photo]"]').val("")
        $('input[id="photo-web-cam"]').val("")
        $("#photo").css("background-image", "none");
        $("#photo").attr('src', '/images/file-upload.png');
        $('#photo').css("height", "240px");
        $('#photo').css("width", "290px");
        $("#imageLabel").html('<i class="folder open icon"></i> Browse Photo');
        $('div[id="message"]').remove()

        var track;
        navigator.mediaDevices.getUserMedia({ video: true, audio: false })
          .then(function(stream) {
            video.srcObject = stream;
            track = stream.getTracks()[0];
            document.getElementById("capture").classList.remove('disabled');
            track.stop();
          })
          .catch(function(err) {
              document.getElementById("capture").classList.add('disabled');
          });

        if ((full_name == "" && birth_date == "")) {
            $('div[id="message"]').remove()
            $('p[role="append_new"]').append(error + '<li>Please enter name and birthdate.</li></ul> </div>')
        } else if (birth_date == "") {
            $('div[id="message"]').remove()
            $('p[role="append_new"]').append(error + '<li>Please enter birthdate.</li> </ul> </div>')
        } else if (full_name == "") {
            $('div[id="message"]').remove()
            $('p[role="append_new"]').append(error + '<li>Please enter name.</li> </ul> </div>')
        } else {
          $('div[id="message"]').remove()
          $('#overlay2').css("display", "block");
            $.ajax({
                url: `/loas/${full_name}/${birth_date}/${coverage}`,
                type: 'get',
                success: function(response) {
                  $('#overlay2').css("display", "none");
                        if (response.accounts == undefined) {
                          $('p[role="append_new"]').append(error + response.message + '</li> </ul> </div>')
                        } else {
                            if (response.accounts == 1) {
                                $('#memberID').val(response.card_no)
                                if ((response.type.toLowerCase() == "principal") || (response.type.toLowerCase() == "Guardian")) {
                                    principal(response)
                                } else if (response.type.toLowerCase() == "dependent") {
                                    dependent(response)
                                }
                                $('#submit_security').on('click', function() {
                                    submit_security(response, "member_details")
                                })
                            $('#modal_member_eligibility').modal('hide')
                            $('input[id="hidden-card-no"]').val(response.card_no)
                            $('div[id="modal_government_id"]').modal({
                                closable: false,
                                autofocus: false,
                                observeChanges: true,
                                transition: 'fade right',
                                onHide: function(){
                                    $("#imageLabel").html('<i class="folder open icon"></i> Browse Photo');
                                    $('#photo').attr('src', '/images/file-upload.png')
                                    $('#photo').attr('style', 'background-image: none; height: 240px; width: 290px;')
                                }
                            }).modal("show");
                            } else {
                              multiple_member(response)
                            }
                        }
                }
            })
        }
    })

  $('.member-card-number').keypress(function(evt) {
    evt = (evt) ? evt : window.event
    var charCode = (evt.which) ? evt.which : evt.keyCode
    if (charCode == 8 || charCode == 37) {
        return true
    } else if (charCode == 46) {
        return false
    } else if (charCode > 31 && charCode != 46 && (charCode < 48 || charCode > 57)) {
        return false
    }
    return true
  })

  // Try another question
    $('#new_security').on('click', function(e) {
        $('#first').removeClass('error')
        $('#first').find('.prompt').remove()
        $('#second').removeClass('error')
        $('#second').find('.prompt').remove()
        $('#first_question').dropdown('clear')
        $('#second_question').dropdown('clear')
        $('#first_question').val('')
        $('#second_question').val('')
        $('div[id="message"]').remove()
        let card_no = $('#memberID').val()
        $.ajax({
            url: `/loas/${card_no}`,
            type: 'get',
            success: function(response) {
                if ((response.type.toLowerCase() == "principal") || (response.type.toLowerCase() == "Guardian")) {
                    principal(response)
                } else if (response.type.toLowerCase() == "dependent") {
                    dependent(response)
                }
                $('#security_modal').modal({
                    transition: 'fade right'
                }).modal('hide')
                $('#security_modal').modal({
                    closable: false,
                    autofocus: false,
                    observeChanges: true,
                    transition: 'fade right',
                    onHide : function(){
                      $('div[id="message"]').remove()
                    }
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
              $('#second_question option.choices').shuffle();
            }
        })
    });

    /*OPTION LIST*/

    /*MEMBER DETAILS CHOOSE OPTION*/
    $("#choose_option_member_details").on("click", function() {
        $('div[id="modal_member_eligibility"]')
            .modal({
                closable: false,
                autofocus: false,
                observeChanges: true,
                onShow: function() {
                    $("#birthdate_picker").calendar({
                        type: "date",
                        maxDate: new Date(),
                        popupOptions: {
                            position: "right center",
                            prefer: "opposite",
                            hideOnScroll: false
                        },
                        inline: false,
                        formatter: {
                            date: function(date, settings) {
                                if (!date) return "";
                                var day = date.getDate() + "";
                                if (day.length < 2) {
                                    day = "0" + day;
                                }
                                var month = date.getMonth() + 1 + "";
                                if (month.length < 2) {
                                    month = "0" + month;
                                }
                                var year = date.getFullYear();
                                return year + "-" + month + "-" + day;
                            }
                        }
                    });
                },

            })
            .modal("show");
    });

    $("#choose_option_member_details").on("mouseover", function() {
        $("#choose_option_member_details").on("click", function() {
            $('div[id="modal_member_eligibility"]')
                .modal({
                    closable: false,
                    autofocus: false,
                    observeChanges: true,
                    onShow: function() {
                        $("#birthdate_picker").calendar({
                            type: "date",
                            maxDate: new Date(),
                            popupOptions: {
                                position: "right center",
                                prefer: "opposite",
                                hideOnScroll: false
                            },
                            inline: false,
                            formatter: {
                                date: function(date, settings) {
                                    if (!date) return "";
                                    var day = date.getDate() + "";
                                    if (day.length < 2) {
                                        day = "0" + day;
                                    }
                                    var month = date.getMonth() + 1 + "";
                                    if (month.length < 2) {
                                        month = "0" + month;
                                    }
                                    var year = date.getFullYear();
                                    return year + "-" + month + "-" + day;
                                }
                            }
                        });
                    },
                    onHide: $element => {
                        $("#full_name").val("");
                        $("#birth_date").val("");
                        $('p[role="append_new"]').html('')
                    }
                })
                .modal("show");
        });
    });

    /*MEMBER DETAILS RETURN CHOOSE OPTION*/

    $('#choose_other_options_details').on('click', function() {
        $('div[id="modal_options"]')
            .modal({
                closable: false,
                autofocus: false,
                observeChanges: true
            })
            .modal('show');
    })

    $('#choose_other_options_details').on('mouseover', function() {
        $('#choose_other_options_details').on('click', function() {
            $('div[id="modal_options"]')
                .modal({
                    closable: false,
                    autofocus: false,
                    observeChanges: true
                })
                .modal('show');
        })
    })

    /*END OF MEMBER DETAILS*/

/* VERIFICATION OPTIONS */
    $('#choose_option_government_id').on('click', function() {
        $('#modal_selection').modal('hide')
        $('div[id="modal_government_id"]')
            .modal({
                closable: false,
                autofocus: false,
                observeChanges: true,
                onHide: function(){
                    $("#imageLabel").html('<i class="folder open icon"></i> Browse Photo');
                    $('#photo').attr('src', '/images/file-upload.png')
                    $('#photo').attr('style', 'background-image: none; height: 240px; width: 290px;')
                }
            })
            .modal('show');
    })

/* CONTENT VERIFYER */

    $('#submit_ID').on('click', function(e){
      if($('#photo').attr('src') == "/images/file-upload.png"){
        let error = '<div id="message" class="ui negative message"><ul class="list">'
        $('div[id="message"]').remove()
        $('p[role="append_new_err"]').append(error + '<li>Please upload a photo.</li> </ul> </div>')
        e.preventDefault()
      } else {
        //Call capture facial image
        $('div[id ="modal_facial_capture"]').modal({
            closeable: false,
            autofocus: false,
            observeChanges: true
            }).modal('show');
      }
    })

  $('#capture').on('click', function(){
    $('div[id = "modal_capture_image"]').attr('class', 'ui tiny modal');
    $('div[id ="modal_capture_image"]').modal({
      closeable: false,
      autofocus: false,
      observeChanges: true
    }).modal('show');
  })

/* SECURITY OPTION */
    $('#choose_option_security_question').on('click', function() {
        $('#modal_selection').modal('hide')
        $('#security_modal').attr('class', 'ui tiny modal');
        $('#security_modal').modal({
            closable: false,
            autofocus: false,
            observeChanges: true,
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
        $('#second_question option.choices').shuffle();
    })


    /*QR CHOOSE OPTION*/
    $('#choose_option_qr').on('click', function() {
        $('div[id="modal_option_qr"]')
            .modal({
                closable: false,
                autofocus: false,
                observeChanges: true
            })
            .modal('show');
    })

    $('#choose_option_qr').on('mouseover', function() {
        $('#choose_option_qr').on('click', function() {
            $('div[id="modal_option_qr"]')
                .modal({
                    closable: false,
                    autofocus: false,
                    observeChanges: true
                })
                .modal('show');
        })
    })

    /*END OF OPTION LIST*/

    /*QR RETURN CHOOSE OPTION*/

    $('#choose_other_options_qr').on('click', function() {
        $('div[id="modal_options"]')
            .modal({
                closable: false,
                autofocus: false,
                observeChanges: true
            })
            .modal('show');
    })

    $('#choose_other_options_qr').on('mouseover', function() {
        $('#choose_other_options_qr').on('click', function() {
            $('div[id="modal_options"]')
                .modal({
                    closable: false,
                    autofocus: false,
                    observeChanges: true
                })
                .modal('show');
        })
    })

    /*END OF QR*/

    /*CARD DETAILS CHOOSE OPTION*/
    $('#choose_option_card').on('click', function() {
        $('div[id="modal_option_card"]')
            .modal({
                closable: false,
                autofocus: false,
                observeChanges: true
            })
            .modal('show');
    })

    /*END OF OPTION LIST*/

    /*CARD DETAILS RETURN CHOOSE OPTION*/

    $('#choose_other_options_card').on('click', function() {
        $('div[id="modal_options"]')
            .modal({
                closable: false,
                autofocus: false,
                observeChanges: true
            })
            .modal('show');
    })

    $('#choose_other_options_card').on('mouseover', function() {
        $('#choose_other_options_card').on('click', function() {
            $('div[id="modal_options"]')
                .modal({
                    closable: false,
                    autofocus: false,
                    observeChanges: true
                })
                .modal('show');
        })
    })

    /*END OF CARD DETAILS*/

    /*EVOUCHER CHOOSE OPTION*/
    $('#choose_option_voucher').on('click', function() {
        $('div[id="modal_option_evoucher"]')
            .modal({
                closable: false,
                autofocus: false,
                observeChanges: true
            })
            .modal('show');
    })

    $('#choose_option_voucher').on('mouseover', function() {
        $('#choose_option_voucher').on('click', function() {
            $('div[id="modal_option_evoucher"]')
                .modal({
                    closable: false,
                    autofocus: false,
                    observeChanges: true
                })
                .modal('show');
        })

    })

    /*END OF OPTION LIST*/

    /*EVOUCHER RETURN CHOOSE OPTION*/

    $('#choose_other_options_evoucher').on('click', function() {
        $('div[id="modal_options"]')
            .modal({
                closable: false,
                autofocus: false,
                observeChanges: true
            })
            .modal('show');
    })

    $('#choose_other_options_evoucher').on('mouseover', function() {
        $('#choose_other_options_evoucher').on('click', function() {
            $('div[id="modal_options"]')
                .modal({
                    closable: false,
                    autofocus: false,
                    observeChanges: true
                })
                .modal('show');
        })
    })

})

onmount('div[id="modal_option_evoucher"]', function() {
    $('#btnEnterEVOUCHER').on('click', function() {
        let voucher_type = $('#selected_type').text()
        let voucher_digit = $('input[name="voucher_no"]').val()
        let error = '<div id="message" class="ui negative message"><ul class="list">'
        $('#voucher_number').val(`${voucher_type}-${voucher_digit}`)

        let voucher_number = $('#voucher_number').val()

        if (voucher_type == "" && voucher_digit == "") {
            $('div[id="message"]').remove()
            $('p[role="append"]').append(error + '<li>Please enter voucher number.</li> </ul> </div>')
        } else if (voucher_type == "") {
            $('div[id="message"]').remove()
            $('p[role="append"]').append(error + '<li>Please select voucher type.</li> </ul> </div>')
        } else if (voucher_digit == "") {
            $('div[id="message"]').remove()
            $('p[role="append"]').append(error + '<li>Please enter voucher digit.</li> </ul> </div>')
        } else {
            $.ajax({
                url: `/loas/validate/evoucher/${voucher_number}/verification`,
                type: 'get',
                success: function(response) {
                    if (response == undefined) {
                        $('div[id="message"]').remove()
                        $('p[role="append2"]').append(error + '<li>' + response.message + '</li> </ul> </div>')
                    } else if (response.message != undefined) {
                        $('div[id="message"]').remove()
                        $('p[role="append2"]').append(error + '<li>' + response.message + '</li> </ul> </div>')
                    } else {
                        $('div[id="message"]').remove()
                        window.document.location = `/loas/${response.id}/e_voucher/redirect`;
                    }
                }
            })
        }
    })
})

onmount('div[role="loa-validation"]', function() {
    let session = $('#session').val()
    $('#cancel_loa').on('click', function() {
        $('div[id="cancel_package_modal"]')
            .modal({
                closable: false,
                autofocus: false,
                observeChanges: true
            })
            .modal('show');
    })

    $('#success_close').on('click', function() {
        $('div#cancel_success_modal')
            .modal({
                closable: false,
                observeChanges: true
            })
            .modal('close');

        let loa_id = $('#loa_id').val()
        if (session == "yes") {
            window.location.href = '/'
        } else {
            window.location.href = 'http://paylinkapiuat.medilink.com.ph/LOA.aspx';
        }
    });
    $('#fail_close').on('click', function() {
        $('#cancel_fail_modal').modal('close');
    });

    $('#cancel').on('click', function() {

        if (session == "yes") {
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
                        let message = "There has been an error cancelling LOA."
                        $('#cancel_fail_modal').find('p[role="message"]').html(message)
                        $('#cancel_fail_modal').attr('class', 'ui tiny modal')
                        $('#cancel_fail_modal').modal({
                            transition: 'fade right',
                            closable: false,
                            observeChanges: true
                        }).modal('show')
                    } else {
                        $('#cancel_main_modal').modal({
                            transition: 'fade right',
                            closable: false,
                            observeChanges: true
                        }).modal('close')
                        $('#cancel_fail_modal').find('p[role="message"]').html(response.message)
                        $('#cancel_fail_modal').attr('class', 'ui tiny modal')
                        $('#cancel_fail_modal').modal({
                            transition: 'fade right',
                            closable: false,
                            observeChanges: true
                        }).modal('show')
                    }
                }
            })
        } else {
            let loe_no = $('#loe_no').val()
            let paylink_user_id = $('#paylink_user_id').val()

            $.ajax({
                url: `/loas/${loe_no}/cancel_loa_no_session/${paylink_user_id}`,
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
        }
    })

    $('#btn_submit').click(function() {
        $('#discharge_date_field').removeClass('error')
        $('#discharge_date_field').find('.prompt').remove()
        let dd_val = $('input[name="loa[discharge_date]"]').val()
        if (dd_val == "") {
            $('#discharge_date_field').addClass('error')
            $('#discharge_date_field').append(`<div class="ui basic red pointing prompt label transition visible">Please enter Discharge Date</div>`)
        } else {
            $('#discharge_date_field').removeClass('error')
            $('#discharge_date_field').find('.prompt').remove()
            $('#confirmation_loa_modal').modal('show')
        }
    })
    $('#loa_acu_confirm_no').on('click', function() {
        $('#confirmation_loa_modal').modal('hide')
    })
    $('#loa_acu_confirm_yes').on('click', function() {
        $('#loa').submit()
    })

    $('#acu_select_package').change(function(){
      $('#acu_select_package').closest('.dropdown').removeClass('error')
      $('#acu_select_package').closest('.field').find('.prompt').remove()
      let selected_package_id = $('#acu_select_package').find(":selected").val()
      let member_pays = $('#acu_select_package').find(":selected").attr('member_pays')
      let payor_pays = $('#acu_select_package').find(":selected").attr('payor_pays')
      let total_pays = $('#acu_select_package').find(":selected").attr('total_pays')
      $('input[name="loa[selected_package]"]').val(selected_package_id)
      $('input[name="loa[member_pays]"]').val(member_pays)
      $('input[name="loa[payor_pays]"]').val(payor_pays)
      $('input[name="loa[total_amount]"]').val(total_pays)

      $('#member_pays').html(`<b>Member Pays<br/>Php. ${member_pays}</b>`)
      $('#payor_pays').html(`<b>Payor Pays<br/>Php. ${payor_pays}</b>`)
      $('#total_amount').html(`<b>Total<br/>Php. ${total_pays}</b>`)
      let p_code = $('#acu_select_package').find(":selected").attr('p_code')
      let p_des = $('#acu_select_package').find(":selected").attr('p_des')
      let append_package = `<tr>
            <td>${p_code}</td>
            <td>${p_des}</td>
          </tr>`
      $('.package_table').find('tbody').find('tr').remove()
      $('.package_table').find('tbody').append(append_package)

      let selected_package = $('#acu_select_package').find(":selected").attr('procedure')
      let procedure_count = $('#acu_select_package').find(":selected").attr('procedure_count')
      let array_procedure = []
      if (selected_package.length > 1){
        array_procedure = selected_package.split("||")
      }else{
        array_procedure.push(selected_package)
      }
      let append_procedure = ``
      for (let i=0;i<procedure_count;i++){
        let array = array_procedure[i].split("|")
        append_procedure += `
          <tr>
            <td>${array[0]}</td>
            <td>${array[1]}</td>
          </tr>
        `
      }
      $('.procedure_table').find('tbody').find('tr').remove()
      $('.procedure_table').find('tbody').append(append_procedure)

      let is_inpatient = $('#acu_select_package').find(":selected").attr('is_inpatient')
      if (is_inpatient == "true"){
        $('.inpatient-date').attr('style', '')
        $('input[name="loa[admission_date]"]').prop('disabled', false);
        $('input[name="loa[discharge_date]"]').prop('disabled', false);
        $('input[name="loa[discharge_date]"]').val('');
      }else{
        $('input[name="loa[admission_date]"]').prop('disabled', true);
        $('input[name="loa[discharge_date]"]').prop('disabled', true);
        $('.inpatient-date').attr('style', 'display: none;')
      }
  })

  $('input[name="loa[soa_reference_no]"]').keypress(function (evt)
  {
    evt = (evt) ? evt : window.event;
    var charCode = (evt.which) ? evt.which : evt.keyCode;
    if (charCode == 8) {
      return true;
    } else if (charCode == 46) {
      return false;
    } else if (charCode > 31 && charCode != 46 && (charCode < 48 || charCode > 57)) {
      return false;
    }
    return true;
  });

})

onmount('#acuSchedCancel', function() {
    $('#acuSchedCancel').click(function() {
        $('#cancelmodal').modal('show')
    })
})

onmount('#show_swall', function() {
    swal({
        title: 'Thank You! Your bill statement has been submitted to Maxicare',
        type: 'success',
        allowOutsideClick: false,
        confirmButtonText: '<i class="check icon"></i> Ok',
        confirmButtonClass: 'ui button primary',
        buttonsStyling: false
    }).then(function() {}).catch(swal.noop)
})

export function principal(response) {
    $('#first').removeClass('error')
    $('#first').find('.prompt').remove()
    $('#second').removeClass('error')
    $('#second').find('.prompt').remove()
    $('#first_question').dropdown('clear')
    $('#second_question').dropdown('clear')
    $('#first_question').val('')
    $('#second_question').val('')

    var items = Array("f3", "f4", "f5", "f6");
    // if (response.email_address != null) {
    //     items.push("f1");
    // }
    // if (response.mobile != null) {
    //     items.push("f2");
    // }
    var item = items[Math.floor(Math.random() * items.length)]
    var index = items.indexOf(item)
    if (index > -1) {
        items.splice(index, 1);
        // if (item == "f1") {
        //     var f1 = items.indexOf("f1")
        //     if (f1 > -1) {
        //         items.splice(f1, 1);
        //     }
        // }
        // if (item == "f2") {
        //     var f2 = items.indexOf("f2")
        //     if (f2 > -1) {
        //         items.splice(f2, 1);
        //     }
        // }
        if (item == "f3") {
            var f3 = items.indexOf("f3")
            if (f3 > -1) {
                items.splice(f3, 1);
            }
        }
        if (item == "f4") {
            var f4 = items.indexOf("f4")
            if (f4 > -1) {
                items.splice(f4, 1);
            }
        }
        if (item == "f5") {
            var f5 = items.indexOf("f5")
            if (f5 > -1) {
                items.splice(f5, 1);
            }
        }
        if (item == "f6") {
            var f6 = items.indexOf("f6")
            if (f6 > -1) {
                items.splice(f6, 1);
            }
        }
    }

    var item2 = items[Math.floor(Math.random() * items.length)]

    let consultations = ""
    if (response.latest_consult != "No") {
        consultations = "Yes"
    } else {
        consultations = "No"
    }
    let number_of_dependents = parseInt(response.number_of_dependents)
    let dependents = ""
    if (number_of_dependents > 0) {
        dependents = "Yes"
    } else {
        dependents = "No"
    }

    var dep_random = [];
    let b = number_of_dependents + 5
    let c1 = number_of_dependents - 5
    let c2 = c1 < 0 ? 0 : c1
    for (var x = c2; x <= b; x++) {
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

    // if (item == "f1") {
    //     var email_address = response.email_address
    //     var arr = email_address.split('@', 2)
    //     var birth_date = response.birth_date
    //     var arr2 = birth_date.split('-', 3)
    //     $('#question1').html('What is your registered email address?')
    //     $('#first_question').empty()
    //     $('#first_question').append($('<option>', {
    //         value: "",
    //         text: "",
    //         class: "disabled"
    //     }))
    //     $('#first_question').append($('<option>', {
    //         value: response.email_address,
    //         text: response.email_address,
    //         class: "choices"
    //     }))
    //     $('#first_question').append($('<option>', {
    //         value: arr[0] + arr2[1] + arr[1],
    //         text: arr[0] + arr2[1] + arr[1],
    //         class: "choices"
    //     }))
    //     $('#first_question').append($('<option>', {
    //         value: arr[0] + arr2[1] + arr2[2] + arr[1],
    //         text: arr[0] + arr2[1] + arr2[2] + arr[1],
    //         class: "choices"
    //     }))
    //     $('#first_answer').val(response.email_address)
    // } else if (item == "f2") {
    //     var mobile = response.mobile
    //     var mobile_last = mobile[mobile.length - 4] + mobile[mobile.length - 3] + mobile[mobile.length - 2] + mobile[mobile.length - 1]
    //     var mobile_random = [];
    //     for (var i = 1000; i <= 9999; i++) {
    //         mobile_random.push(i);
    //     }
    //     var mobile_index = mobile_random.indexOf(Number(mobile_last))
    //     mobile_random.splice(mobile_index, 1)
    //     var mr1 = mobile_random[Math.floor(Math.random() * mobile_random.length)]
    //     var mr_index = mobile_random.indexOf(mr1)
    //     if (mr_index > -1) {
    //         mobile_random.splice(mr_index, 1)
    //     }
    //     var mr2 = mobile_random[Math.floor(Math.random() * mobile_random.length)]
    //     $('#question1').html('What is the last 4-digits of your registered mobile number?')
    //     $('#first_question').empty()
    //     $('#first_question').append($('<option>', {
    //         value: "",
    //         text: "",
    //         class: "disabled"
    //     }))
    //     $('#first_question').append($('<option>', {
    //         value: mobile_last,
    //         text: mobile_last,
    //         class: "choices"
    //     }))
    //     $('#first_question').append($('<option>', {
    //         value: String(mr1),
    //         text: String(mr1),
    //         class: "choices"
    //     }))
    //     $('#first_question').append($('<option>', {
    //         value: String(mr2),
    //         text: String(mr2),
    //         class: "choices"
    //     }))
    //     $('#first_answer').val(mobile_last)
    // } else
    if (item == "f3") {
        $('#question1').html('Have you had consultation/s for the last month?')
        $('#first_question').empty()
        $('#first_question').append($('<option>', {
            value: "",
            text: "",
            class: "disabled"
        }))
        $('#first_question').append($('<option>', {
            value: "Yes",
            text: "Yes"
        }))
        $('#first_question').append($('<option>', {
            value: "No",
            text: "No"
        }))
        $('#first_answer').val(consultations)
    } else if (item == "f4") {
        $('#question1').html('Do you have dependents enrolled in Maxicare?')
        $('#first_question').empty()
        $('#first_question').append($('<option>', {
            value: "",
            text: "",
            class: "disabled"
        }))
        $('#first_question').append($('<option>', {
            value: "Yes",
            text: "Yes"
        }))
        $('#first_question').append($('<option>', {
            value: "No",
            text: "No"
        }))
        $('#first_answer').val(dependents)
    } else if (item == "f5") {
        $('#question1').html('How many of your dependents are enrolled in Maxicare?')
        $('#first_question').empty()
        $('#first_question').append($('<option>', {
            value: "",
            text: "",
            class: "disabled"
        }))
        $('#first_question').append($('<option>', {
            value: response.number_of_dependents,
            text: response.number_of_dependents,
            class: "choices"
        }))
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
    } else if (item == "f6") {
        let last_facility = ""
          if (response.last_facility != "") {
              last_facility = response.last_facility
          } else {
              last_facility = "None"
          }
        $('#question1').html('What is the last hospital/clinic/lab you have visited?')
        $('#first_question').empty()
        $('#first_question').append($('<option>', {
            value: "",
            text: "",
            class: "disabled"
        }))
        $('#first_question').append($('<option>', {
            value: last_facility,
            text: last_facility,
            class: "choices"
        }))
        $('#first_question').append($('<option>', {
            value: response.random_facility1,
            text: response.random_facility1,
            class: "choices"
        }))
        $('#first_question').append($('<option>', {
            value: response.random_facility2,
            text: response.random_facility2,
            class: "choices"
        }))
        $('#first_answer').val(last_facility)
    }

    // if (item2 == "f1") {
    //     var email_address = response.email_address
    //     var arr = email_address.split('@', 2)
    //     var birth_date = response.birth_date
    //     var arr2 = birth_date.split('-', 3)
    //     $('#question2').html('What is your registered email address?')
    //     $('#second_question').empty()
    //     $('#second_question').append($('<option>', {
    //         value: "",
    //         text: "",
    //         class: "disabled"
    //     }))
    //     $('#second_question').append($('<option>', {
    //         value: response.email_address,
    //         text: response.email_address,
    //         class: "choices"
    //     }))
    //     $('#second_question').append($('<option>', {
    //         value: arr[0] + arr2[1] + arr[1],
    //         text: arr[0] + arr2[1] + arr[1],
    //         class: "choices"
    //     }))
    //     $('#second_question').append($('<option>', {
    //         value: arr[0] + arr2[1] + arr2[2] + arr[1],
    //         text: arr[0] + arr2[1] + arr2[2] + arr[1],
    //         class: "choices"
    //     }))
    //     $('#second_answer').val(response.email_address)
    // } else if (item2 == "f2") {
    //     var mobile = response.mobile
    //     var mobile_last = mobile[mobile.length - 4] + mobile[mobile.length - 3] + mobile[mobile.length - 2] + mobile[mobile.length - 1]
    //     var mobile_random = [];
    //     for (var i = 1000; i <= 9999; i++) {
    //         mobile_random.push(i);
    //     }
    //     var mobile_index = mobile_random.indexOf(Number(mobile_last))
    //     mobile_random.splice(mobile_index, 1)
    //     var mr1 = mobile_random[Math.floor(Math.random() * mobile_random.length)]
    //     var mr_index = mobile_random.indexOf(mr1)
    //     if (mr_index > -1) {
    //         mobile_random.splice(mr_index, 1)
    //     }
    //     var mr2 = mobile_random[Math.floor(Math.random() * mobile_random.length)]
    //     $('#question2').html('What is the last 4-digits of your registered mobile number?')
    //     $('#second_question').empty()
    //     $('#second_question').append($('<option>', {
    //         value: "",
    //         text: "",
    //         class: "disabled"
    //     }))
    //     $('#second_question').append($('<option>', {
    //         value: mobile_last,
    //         text: mobile_last,
    //         class: "choices"
    //     }))
    //     $('#second_question').append($('<option>', {
    //         value: String(mr1),
    //         text: String(mr1),
    //         class: "choices"
    //     }))
    //     $('#second_question').append($('<option>', {
    //         value: String(mr2),
    //         text: String(mr2),
    //         class: "choices"
    //     }))
    //     $('#second_answer').val(mobile_last)
    // } else
    if (item2 == "f3") {
        $('#question2').html('Have you had consultation/s for the last month?')
        $('#second_question').empty()
        $('#second_question').append($('<option>', {
            value: "",
            text: "",
            class: "disabled"
        }))
        $('#second_question').append($('<option>', {
            value: "Yes",
            text: "Yes"
        }))
        $('#second_question').append($('<option>', {
            value: "No",
            text: "No"
        }))
        $('#second_answer').val(consultations)
    } else if (item2 == "f4") {
        $('#question2').html('Do you have dependents enrolled in Maxicare?')
        $('#second_question').empty()
        $('#second_question').append($('<option>', {
            value: "",
            text: "",
            class: "disabled"
        }))
        $('#second_question').append($('<option>', {
            value: "Yes",
            text: "Yes"
        }))
        $('#second_question').append($('<option>', {
            value: "No",
            text: "No"
        }))
        $('#second_answer').val(dependents)
    } else if (item2 == "f5") {
        $('#question2').html('How many of your dependents are enrolled in Maxicare?')
        $('#second_question').empty()
        $('#second_question').append($('<option>', {
            value: "",
            text: "",
            class: "disabled"
        }))
        $('#second_question').append($('<option>', {
            value: response.number_of_dependents,
            text: response.number_of_dependents,
            class: "choices"
        }))
        $('#second_question').append($('<option>', {
            value: String(dp1),
            text: String(dp1),
            class: "choices"
        }))
        $('#second_question').append($('<option>', {
            value: String(dp2),
            text: String(dp2),
            class: "choices"
        }))
        $('#second_answer').val(response.number_of_dependents)
    } else if (item2 == "f6") {
        let last_facility = ""
          if (response.last_facility != "") {
              last_facility = response.last_facility
          } else {
              last_facility = "None"
          }
        $('#question2').html('What is the last hospital/clinic/lab you have visited?')
        $('#second_question').empty()
        $('#second_question').append($('<option>', {
            value: "",
            text: "",
            class: "disabled"
        }))
        $('#second_question').append($('<option>', {
            value: last_facility,
            text: last_facility,
            class: "choices"
        }))
        $('#second_question').append($('<option>', {
            value: response.random_facility1,
            text: response.random_facility1,
            class: "choices"
        }))
        $('#second_question').append($('<option>', {
            value: response.random_facility2,
            text: response.random_facility2,
            class: "choices"
        }))
        $('#second_answer').val(last_facility)
    }
}

export function dependent(response) {
    $('#first').removeClass('error')
    $('#first').find('.prompt').remove()
    $('#second').removeClass('error')
    $('#second').find('.prompt').remove()
    $('#first_question').dropdown('clear')
    $('#second_question').dropdown('clear')
    $('#first_question').val('')
    $('#second_question').val('')

    let fname_random = [
        'James', 'Mary', 'John', 'Patricia', 'Robert', 'Jennifer', 'Michael', 'Linda', 'William', 'Elizabeth', 'David',
        'Barbara', 'Richard', 'Susan', 'Joseph', 'Jessica', 'Thomas', 'Sarah', 'Charles', 'Margaret', 'Christopher', 'Karen',
        'Daniel', 'Nancy', 'Matthew', 'Lisa', 'Anthony', 'Betty', 'Donald', 'Dorothy', 'Mark', 'Sandra', 'Paul', 'Ashley',
        'Steven', 'Kimberly', 'Andrew', 'Donna', 'Kenneth', 'Emily', 'George', 'Carol', 'Joshua', 'Michelle', 'Kevin', 'Amanda',
        'Brian', 'Melissa', 'Edward', 'Deborah', 'Ronald', 'Stephanie', 'Timothy', 'Rebecca', 'Jason', 'Laura', 'Jeffrey', 'Helen',
        'Ryan', 'Sharon', 'Jacob', 'Cynthia', 'Gary', 'Kathleen', 'Nicholas', 'Amy', 'Eric', 'Shirley', 'Stephen', 'Angela', 'Jonathan',
        'Anna', 'Larry', 'Ruth', 'Justin', 'Brenda', 'Scott', 'Pamela', 'Brandon', 'Nicole', 'Frank', 'Katherine', 'Benjamin', 'Samantha',
        'Gregory', 'Christine', 'Raymond', 'Catherine', 'Samuel', 'Virginia', 'Patrick', 'Debra', 'Alexander', 'Rachel', 'Jack',
        'Janet', 'Dennis', 'Emma', 'Jerry', 'Carolyn', 'Tyler', 'Maria', 'Aaron', 'Heather', 'Henry', 'Diane', 'Jose', 'Julie', 'Douglas',
        'Joyce', 'Peter', 'Evelyn', 'Adam', 'Joan', 'Nathan', 'Victoria', 'Zachary', 'Kelly', 'Walter', 'Christina', 'Kyle', 'Lauren',
        'Harold', 'Frances', 'Carl', 'Martha', 'Jeremy', 'Judith', 'Gerald', 'Cheryl', 'Keith', 'Megan', 'Roger', 'Andrea', 'Arthur', 'Olivia',
        'Terry', 'Ann', 'Lawrence', 'Jean', 'Sean', 'Alice', 'Christian', 'Jacqueline', 'Ethan', 'Hannah', 'Austin', 'Doris', 'Joe',
        'Kathryn', 'Albert', 'Gloria', 'Jesse', 'Teresa', 'Willie', 'Sara', 'Billy', 'Janice', 'Bryan', 'Marie', 'Bruce', 'Julia', 'Noah',
        'Grace', 'Jordan', 'Judy', 'Dylan', 'Theresa', 'Ralph', 'Madison', 'Roy', 'Beverly', 'Alan', 'Denise', 'Wayne', 'Marilyn', 'Eugene',
        'Amber', 'Juan', 'Danielle', 'Gabriel', 'Rose', 'Louis', 'Brittany', 'Russell', 'Diana', 'Randy', 'Abigail', 'Vincent', 'Natalie',
        'Philip', 'Jane', 'Logan', 'Lori', 'Bobby', 'Alexis', 'Harry', 'Tiffany', 'Johnny', 'Kayla'
    ]
    let rl_random = ['Parent', 'Child', 'Spouse / Partner', 'Sibling']

    var items = Array("f3", "f6", "f7", "f8");
    // if (response.email_address != null) {
    //     items.push("f1");
    // }
    // if (response.mobile != null) {
    //     items.push("f2");
    // }
    var item = items[Math.floor(Math.random() * items.length)]
    var index = items.indexOf(item)
    if (index > -1) {
        items.splice(index, 1);
        // if (item == "f1") {
        //     var f1 = items.indexOf("f1")
        //     if (f1 > -1) {
        //         items.splice(f1, 1);
        //     }
        // }
        // if (item == "f2") {
        //     var f2 = items.indexOf("f2")
        //     if (f2 > -1) {
        //         items.splice(f2, 1);
        //     }
        // }
        if (item == "f3") {
            var f3 = items.indexOf("f3")
            if (f3 > -1) {
                items.splice(f3, 1);
            }
        }
        if (item == "f6") {
            var f6 = items.indexOf("f6")
            if (f6 > -1) {
                items.splice(f6, 1);
            }
        }
        if (item == "f7") {
            var f7 = items.indexOf("f7")
            if (f7 > -1) {
                items.splice(f7, 1);
            }
        }
        if (item == "f8") {
            var f8 = items.indexOf("f8")
            if (f8 > -1) {
                items.splice(f8, 1);
            }
        }
    }

    var item2 = items[Math.floor(Math.random() * items.length)]

    let consultations = ""
    if (response.latest_consult != "No") {
        consultations = "Yes"
    } else {
        consultations = "No"
    }

    // if (item == "f1") {
    //     var email_address = response.email_address
    //     var arr = email_address.split('@', 2)
    //     var birth_date = response.birth_date
    //     var arr2 = birth_date.split('-', 3)
    //     $('#question1').html('What is your registered email address?')
    //     $('#first_question').empty()
    //     $('#first_question').append($('<option>', {
    //         value: "",
    //         text: "",
    //         class: "disabled"
    //     }))
    //     $('#first_question').append($('<option>', {
    //         value: response.email_address,
    //         text: response.email_address,
    //         class: "choices"
    //     }))
    //     $('#first_question').append($('<option>', {
    //         value: arr[0] + arr2[1] + arr[1],
    //         text: arr[0] + arr2[1] + arr[1],
    //         class: "choices"
    //     }))
    //     $('#first_question').append($('<option>', {
    //         value: arr[0] + arr2[1] + arr2[2] + arr[1],
    //         text: arr[0] + arr2[1] + arr2[2] + arr[1],
    //         class: "choices"
    //     }))
    //     $('#first_answer').val(response.email_address)
    // } else if (item == "f2") {
    //     var mobile = response.mobile
    //     var mobile_last = mobile[mobile.length - 4] + mobile[mobile.length - 3] + mobile[mobile.length - 2] + mobile[mobile.length - 1]
    //     var mobile_random = [];
    //     for (var i = 1000; i <= 9999; i++) {
    //         mobile_random.push(i);
    //     }
    //     var mobile_index = mobile_random.indexOf(Number(mobile_last))
    //     mobile_random.splice(mobile_index, 1)
    //     var mr1 = mobile_random[Math.floor(Math.random() * mobile_random.length)]
    //     var mr_index = mobile_random.indexOf(mr1)
    //     if (mr_index > -1) {
    //         mobile_random.splice(mr_index, 1)
    //     }
    //     var mr2 = mobile_random[Math.floor(Math.random() * mobile_random.length)]
    //     $('#question1').html('What is the last 4-digits of your registered mobile number?')
    //     $('#first_question').empty()
    //     $('#first_question').append($('<option>', {
    //         value: "",
    //         text: "",
    //         class: "disabled"
    //     }))
    //     $('#first_question').append($('<option>', {
    //         value: mobile_last,
    //         text: mobile_last,
    //         class: "choices"
    //     }))
    //     $('#first_question').append($('<option>', {
    //         value: String(mr1),
    //         text: String(mr1),
    //         class: "choices"
    //     }))
    //     $('#first_question').append($('<option>', {
    //         value: String(mr2),
    //         text: String(mr2),
    //         class: "choices"
    //     }))
    //     $('#first_answer').val(mobile_last)
    // } else
    if (item == "f3") {
        $('#question1').html('Have you had consultation/s for the last month?')
        $('#first_question').empty()
        $('#first_question').append($('<option>', {
            value: "",
            text: "",
            class: "disabled"
        }))
        $('#first_question').append($('<option>', {
            value: "Yes",
            text: "Yes"
        }))
        $('#first_question').append($('<option>', {
            value: "No",
            text: "No"
        }))
        $('#first_answer').val(consultations)
    } else if (item == "f6") {
        let last_facility = ""
          if (response.last_facility != "") {
              last_facility = response.last_facility
          } else {
              last_facility = "None"
          }
        $('#question1').html('What is the last hospital/clinic/lab you have visited?')
        $('#first_question').empty()
        $('#first_question').append($('<option>', {
            value: "",
            text: "",
            class: "disabled"
        }))
        $('#first_question').append($('<option>', {
            value: last_facility,
            text: last_facility,
            class: "choices"
        }))
        $('#first_question').append($('<option>', {
            value: response.random_facility1,
            text: response.random_facility1,
            class: "choices"
        }))
        $('#first_question').append($('<option>', {
            value: response.random_facility2,
            text: response.random_facility2,
            class: "choices"
        }))
        $('#first_answer').val(last_facility)
    } else if (item == "f7") {
        var fname_index = fname_random.indexOf(response.principal)
        fname_random.splice(fname_index, 1)
        var fn1 = fname_random[Math.floor(Math.random() * fname_random.length)]
        var fn_index = fname_random.indexOf(fn1)
        if (fn_index > -1) {
            fname_random.splice(fn_index, 1)
        }
        var fn2 = fname_random[Math.floor(Math.random() * fname_random.length)]
        $('#question1').html('What is your principal’s first name?')
        $('#first_question').empty()
        $('#first_question').append($('<option>', {
            value: "",
            text: "",
            class: "disabled"
        }))
        $('#first_question').append($('<option>', {
            value: response.principal,
            text: response.principal,
            class: "choices"
        }))
        $('#first_question').append($('<option>', {
            value: fn1,
            text: fn1,
            class: "choices"
        }))
        $('#first_question').append($('<option>', {
            value: fn2,
            text: fn2,
            class: "choices"
        }))
        $('#first_answer').val(response.principal)
    } else if (item == "f8") {
        let relationship = ""
        if(response.relationship.toLowerCase() == "spouse"){
          relationship = "Spouse / Partner"
        }
        else if(response.relationship.toLowerCase() == "partner"){
          relationship = "Spouse / Partner"
        }
        else{
          relationship = response.relationship
        }
        var rl_index = rl_random.indexOf(relationship)
        rl_random.splice(rl_index, 1)
        var rl1 = rl_random[Math.floor(Math.random() * rl_random.length)]
        var rl_index = rl_random.indexOf(rl1)
        if (rl_index > -1) {
            rl_random.splice(rl_index, 1)
        }
        var rl2 = rl_random[Math.floor(Math.random() * rl_random.length)]
        $('#question1').html('How are you related to your principal?')
        $('#first_question').empty()
        $('#first_question').append($('<option>', {
            value: "",
            text: "",
            class: "disabled"
        }))
        $('#first_question').append($('<option>', {
            value: relationship,
            text: relationship,
            class: "choices"
        }))
        $('#first_question').append($('<option>', {
            value: rl1,
            text: rl1,
            class: "choices"
        }))
        $('#first_question').append($('<option>', {
            value: rl2,
            text: rl2,
            class: "choices"
        }))
        $('#first_answer').val(relationship)
    }

    // if (item2 == "f1") {
    //     var email_address = response.email_address
    //     var arr = email_address.split('@', 2)
    //     var birth_date = response.birth_date
    //     var arr2 = birth_date.split('-', 3)
    //     $('#question2').html('What is your registered email address?')
    //     $('#second_question').empty()
    //     $('#second_question').append($('<option>', {
    //         value: "",
    //         text: "",
    //         class: "disabled"
    //     }))
    //     $('#second_question').append($('<option>', {
    //         value: response.email_address,
    //         text: response.email_address,
    //         class: "choices"
    //     }))
    //     $('#second_question').append($('<option>', {
    //         value: arr[0] + arr2[1] + arr[1],
    //         text: arr[0] + arr2[1] + arr[1],
    //         class: "choices"
    //     }))
    //     $('#second_question').append($('<option>', {
    //         value: arr[0] + arr2[1] + arr2[2] + arr[1],
    //         text: arr[0] + arr2[1] + arr2[2] + arr[1],
    //         class: "choices"
    //     }))
    //     $('#second_answer').val(response.email_address)
    // } else if (item2 == "f2") {
    //     var mobile = response.mobile
    //     var mobile_last = mobile[mobile.length - 4] + mobile[mobile.length - 3] + mobile[mobile.length - 2] + mobile[mobile.length - 1]
    //     var mobile_random = [];
    //     for (var i = 1000; i <= 9999; i++) {
    //         mobile_random.push(i);
    //     }
    //     var mobile_index = mobile_random.indexOf(Number(mobile_last))
    //     mobile_random.splice(mobile_index, 1)
    //     var mr1 = mobile_random[Math.floor(Math.random() * mobile_random.length)]
    //     var mr_index = mobile_random.indexOf(mr1)
    //     if (mr_index > -1) {
    //         mobile_random.splice(mr_index, 1)
    //     }
    //     var mr2 = mobile_random[Math.floor(Math.random() * mobile_random.length)]
    //     $('#question2').html('What is the last 4-digits of your registered mobile number?')
    //     $('#second_question').empty()
    //     $('#second_question').append($('<option>', {
    //         value: "",
    //         text: "",
    //         class: "disabled"
    //     }))
    //     $('#second_question').append($('<option>', {
    //         value: mobile_last,
    //         text: mobile_last,
    //         class: "choices"
    //     }))
    //     $('#second_question').append($('<option>', {
    //         value: String(mr1),
    //         text: String(mr1),
    //         class: "choices"
    //     }))
    //     $('#second_question').append($('<option>', {
    //         value: String(mr2),
    //         text: String(mr2),
    //         class: "choices"
    //     }))
    //     $('#second_answer').val(mobile_last)
    // } else
    if (item2 == "f3") {
        $('#question2').html('Have you had consultation/s for the last month?')
        $('#second_question').empty()
        $('#second_question').append($('<option>', {
            value: "",
            text: "",
            class: "disabled"
        }))
        $('#second_question').append($('<option>', {
            value: "Yes",
            text: "Yes"
        }))
        $('#second_question').append($('<option>', {
            value: "No",
            text: "No"
        }))
        $('#second_answer').val(consultations)
    } else if (item2 == "f6") {
        let last_facility = ""
          if (response.last_facility != "") {
              last_facility = response.last_facility
          } else {
              last_facility = "None"
          }
        $('#question2').html('What is the last hospital/clinic/lab you have visited?')
        $('#second_question').empty()
        $('#second_question').append($('<option>', {
            value: "",
            text: "",
            class: "disabled"
        }))
        $('#second_question').append($('<option>', {
            value: last_facility,
            text: last_facility,
            class: "choices"
        }))
        $('#second_question').append($('<option>', {
            value: response.random_facility1,
            text: response.random_facility1,
            class: "choices"
        }))
        $('#second_question').append($('<option>', {
            value: response.random_facility2,
            text: response.random_facility2,
            class: "choices"
        }))
        $('#second_answer').val(last_facility)
    } else if (item2 == "f7") {
        var fname_index = fname_random.indexOf(response.principal)
        fname_random.splice(fname_index, 1)
        var fn1 = fname_random[Math.floor(Math.random() * fname_random.length)]
        var fn_index = fname_random.indexOf(fn1)
        if (fn_index > -1) {
            fname_random.splice(fn_index, 1)
        }
        var fn2 = fname_random[Math.floor(Math.random() * fname_random.length)]
        $('#question2').html('What is your principal’s first name?')
        $('#second_question').empty()
        $('#second_question').append($('<option>', {
            value: "",
            text: "",
            class: "disabled"
        }))
        $('#second_question').append($('<option>', {
            value: response.principal,
            text: response.principal,
            class: "choices"
        }))
        $('#second_question').append($('<option>', {
            value: fn1,
            text: fn1,
            class: "choices"
        }))
        $('#second_question').append($('<option>', {
            value: fn2,
            text: fn2,
            class: "choices"
        }))
        $('#second_answer').val(response.principal)
    } else if (item2 == "f8") {
        let relationship = ""
        if(response.relationship.toLowerCase() == "spouse"){
          relationship = "Spouse / Partner"
        }
        else if(response.relationship.toLowerCase() == "partner"){
          relationship = "Spouse / Partner"
        }
        else{
          relationship = response.relationship
        }
        var rl_index = rl_random.indexOf(relationship)
        rl_random.splice(rl_index, 1)
        var rl1 = rl_random[Math.floor(Math.random() * rl_random.length)]
        var rl_index = rl_random.indexOf(rl1)
        if (rl_index > -1) {
            rl_random.splice(rl_index, 1)
        }
        var rl2 = rl_random[Math.floor(Math.random() * rl_random.length)]
        $('#question2').html('How are you related to your principal?')
        $('#second_question').empty()
        $('#second_question').append($('<option>', {
            value: "",
            text: "",
            class: "disabled"
        }))
        $('#second_question').append($('<option>', {
            value: relationship,
            text: relationship,
            class: "choices"
        }))
        $('#second_question').append($('<option>', {
            value: rl1,
            text: rl1,
            class: "choices"
        }))
        $('#second_question').append($('<option>', {
            value: rl2,
            text: rl2,
            class: "choices"
        }))
        $('#second_answer').val(relationship)
    }
}

export function submit_security(response, verification) {
    let error = '<div id="message" class="ui negative message"><ul class="list">'
    let first_question = $('#first_question').find(":selected").text()
    let second_question = $('#second_question').val()
    if (first_question == "") {
        $('#first').removeClass('error')
        $('#first').find('.prompt').remove()
        $('#first').addClass('error')
        $('#first').append(`<div class="ui basic red pointing prompt label transition visible">Please select an answer</div>`)
        $('p[role="append_security"]').empty()
    }
    if (second_question == "") {
        $('#second').removeClass('error')
        $('#second').find('.prompt').remove()
        $('#second').addClass('error')
        $('#second').append(`<div class="ui basic red pointing prompt label transition visible">Please select an answer</div>`)
        $('p[role="append_security"]').empty()
    }
    if ((first_question != "" && second_question != "")) {
        $('#first').removeClass('error')
        $('#first').find('.prompt').remove()
        $('#second').removeClass('error')
        $('#second').find('.prompt').remove()
        if (($('#first_question').find(":selected").text() == $('#first_answer').val()) && ($('#second_question').find(":selected").text() == $('#second_answer').val())) {
            // window.document.location = `/loas/${response.card_no}/${verification}/redirect/ACU`
            $('div[id = "modal_facial_capture"]').attr('class', 'ui tiny modal');
            $('div[id ="modal_facial_capture"]').modal({
              closeable: false,
              autofocus: false,
              observeChanges: true
              }).modal('show');
        } else {
            var i = parseInt($('#attempt').val())
            var j = parseInt($('#attempt').val()) + 1
            $('#attempt').val(i + 1)
            let datetime = new Date()
            $.ajax({
                url: `/loas/${response.card_no}/attempt`,
                type: 'get',
                success: function(response) {
                    if (response.message == "blocked") {
                        let member_id = response.id
                        $('div[id="message"]').remove()
                        $('#first_question').dropdown('clear')
                        $('#second_question').dropdown('clear')
                        // $('p[role="append_security"]').append(error + '<li>You have entered an incorrect answer to the security question, Member has been blocked for 1 day.</li> </ul> </div>')

                        swal({
                          html: '<center>Member was not able to provide correct answers to the security questions and is now BLOCKED. To Unblock, Please upload a copy of the member\'s valid government issued id</center>',
                          type: 'warning',
                          confirmButtonText: '<i class="check icon"></i> Ok',
                          confirmButtonClass: 'ui button',
                          buttonsStyling: false,
                          reverseButtons: true,
                          allowOutsideClick: false
                        }).then(function() {
                          $('div[id="modal_government_id"]').modal({
                            closable: false,
                            autofocus: false,
                            observeChanges: true,
                            transition: 'fade right',
                            onHide: function(){
                              $("#imageLabel").html('<i class="folder open icon"></i> Browse Photo');
                              $('#photo').attr('src', '/images/file-upload.png')
                              $('#photo').attr('style', 'background-image: none; height: 240px; width: 290px;')
                            }
                          }).modal("show");
                        })

                    } else {
                        $('div[id="message"]').remove()
                        $('#first_question').dropdown('clear')
                        $('#second_question').dropdown('clear')
                        $('p[role="append_security"]').append(error + '<li>You have entered an incorrect answer to the security question</li> </ul> </div>')
                    }
                }
            })
        }
    }
    $("#first_question").on('change', function(e) {
        $('#first').removeClass('error')
        $('#first').find('.prompt').remove()
    })
    $("#second_question").on('change', function(e) {
        $('#second').removeClass('error')
        $('#second').find('.prompt').remove()
    })
}

function multiple_member(response) {
    let members = response.member
    $(".new_row").remove()
    for (let member of members) {
        let new_row =
            `<div class="sixteen wide tablet eight wide computer column new_row">\
                <div class="ui card" member_card="${member.card_no}" member_birth_date="${member.birth_date}">\
                  <input type="hidden" id="memberID">\
                  <div class="content" style="cursor:pointer">\
                    <div class="ui small feed">\
                      <div class="event">\
                        <div class="content">\
                          <div class="summary">\
                            <div class="ui grid">\
                              <div class="one column row">\
                                <div class="column description">\
                                  <b>Card Number: </b>\
                                  <p>${member.card_no}</p>\
                                </div>\
                              </div>\
                            </div>\
                          </div>\
                        </div>\
                      </div>\
                      <div class="event">\
                        <div class="content">\
                          <div class="summary">\
                            <div class="ui grid">\
                              <div class="one column row">\
                                <div class="column description">\
                                  <b>Full Name: </b>\
                                  <p>${member.name}</p>\
                                </div>\
                              </div>\
                            </div>\
                          </div>\
                        </div>\
                      </div>\
                      <div class="event">\
                        <div class="content">\
                          <div class="summary">\
                            <div class="ui grid">\
                              <div class="one column row">\
                                <div class="column description">\
                                  <b>Account Name: </b>\
                                  <p>${member.account_name}</p>\
                                </div>\
                              </div>\
                            </div>\
                          </div>\
                        </div>\
                      </div>\
                      <div class="event">\
                        <div class="content">\
                          <div class="summary">\
                            <div class="ui grid">\
                              <div class="one column row">\
                                <div class="column description">\
                                  <b>Member Type: </b>\
                                  <p>${member.type}</p>\
                                </div>\
                              </div>\
                            </div>\
                          </div>\
                        </div>\
                      </div>\
                    </div>\
                  </div>\
                </div>\
              </div>`
        $("#member_append").append(new_row)

    }

    $('#modal_member_eligibility').modal('hide')
    $('#validate_member_account').modal({
        closable: false,
        autofocus: false,
        observeChanges: true,
        transition: 'fade right',
        onHide: function() {
            $('div[id="message"]').remove()
            $('#status').val('')
        }
    }).modal("show");

    $('#validate_member_account').find('.card').on('click', function() {
        $('.card').removeAttr("style")
        $(this).css("background-color", "#00DDFB");
        $('#status').val('true');
        $('div[id="message"]').html('');
        $('div[id="message"]').hide();
        $('#redirect_mobile').prop("disabled", false)
        let member_card = $(this).attr('member_card')
        let member_remarks = $(this).attr('member_birth_date')
        $('#memberID').val(member_card)
        $('#member_remarks').val(member_remarks)
    });

    $('#redirect_mobile').on('click', function(e) {
        let error = '<div id="message" class="ui negative message"><ul class="list">'
        let card_no = $('#memberID').val()
        let bdate = $('#member_remarks').val()

        if ($('#status').val() == "") {
            $('div[id="message"]').remove()
            $('#append_validation').append(error + `<li>Please select Member's Account</li> </ul> </div>`)
        } else {
            $('div[id="message"]').remove()
            $.ajax({
                url: `/loas/card/${card_no}/with_loa_validation/${bdate}/ACU`,
                type: 'get',
                success: function(response) {
                  console.log(response)
                    if (response.type == undefined) {
                      $('div[id="message"]').remove()
                      $('#append_validation').append(error + `<li>${response.message}</li> </ul> </div>`)
                    } else {
                      $('#memberID').val(response.card_no)
                      if ((response.type.toLowerCase() == "principal") || (response.type.toLowerCase() == "Guardian")) {
                          principal(response)
                      } else if (response.type.toLowerCase() == "dependent") {
                          dependent(response)
                      }
                      $('#submit_security').on('click', function() {
                          submit_security(response, "member_details")
                      })

                      $('div[id="message"]').remove()
                      $('#modal_member_eligibility').modal('hide')
                      $('input[id="hidden-card-no"]').val(response.card_no)
                      $('div[id="modal_government_id"]').modal({
                        closable: false,
                        autofocus: false,
                        observeChanges: true,
                        transition: 'fade right',
                        onHide: function(){
                            $("#imageLabel").html('<i class="folder open icon"></i> Browse Photo');
                            $('#photo').attr('src', '/images/file-upload.png')
                            $('#photo').attr('style', 'background-image: none; height: 240px; width: 290px;')
                        }
                      }).modal("show");
                    }
                }
            })
        }
    });

}
