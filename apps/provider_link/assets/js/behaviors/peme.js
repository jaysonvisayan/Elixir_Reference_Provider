onmount('a[id="open_peme"]', function() {
  $('#open_peme').on('click', function() {
    $('#coverage').val('PEME');
    $("#peme_modal_options").modal("show")
  });

  // EVOUCHER

  $('#peme_choose_option_evoucher').on('click', function() {
    $('div[id="peme_modal_option_evoucher"]')
        .modal({
            closable: false,
            autofocus: false,
            observeChanges: true
        })
        .modal('show');
  })

  $('#peme_choose_option_evoucher').on('mouseover', function() {
      $('#peme_choose_option_evoucher').on('click', function() {
          $('div[id="peme_modal_option_evoucher"]')
              .modal({
                  closable: false,
                  autofocus: false,
                  observeChanges: true
              })
              .modal('show');
      })
  })

  $('#peme_choose_option_qr_code').on('click', function() {
    $('div[id="peme_modal_option_qrcode"]')
        .modal({
            closable: false,
            autofocus: false,
            observeChanges: true
        })
        .modal('show');
        LoadControl()
  })

  function LoadControl() {
    //Load the control manually
    Dynamsoft.WebTwainEnv.Load();
  }

  function UnloadControl() {
    //Unload the control manually
    Dynamsoft.WebTwainEnv.Unload();
  }

  // CHOOSE OTHER OPTION EVOUCHER

  $('#peme_choose_other_options_evoucher').on('click', function() {
    $('div[id="peme_modal_options"]')
        .modal({
            closable: false,
            autofocus: false,
            observeChanges: true
        })
        .modal('show');
  })

  $('#peme_choose_other_options_evoucher').on('mouseover', function() {
      $('#peme_choose_other_options_evoucher').on('click', function() {
          $('div[id="peme_modal_options"]')
              .modal({
                  closable: false,
                  autofocus: false,
                  observeChanges: true
              })
              .modal('show');
      })
  })

  $('#peme_choose_other_options_qrcode').on('click', function() {
    $('div[id="peme_modal_options"]')
        .modal({
            closable: false,
            autofocus: false,
            observeChanges: true
        })
        .modal('show');
        UnloadControl()
    $('#peme_modal_option_qrcode').modal('hide');
  })

  //START DYNAMSOFT
  Dynamsoft.WebTwainEnv.RegisterEvent('OnWebTwainReady', Dynamsoft_OnReady);
  var DWObject;


$('#qr_verify_image').on('click', function() {
    UploadImage()

})

$('input[id="acquired_img"]').on('click', function() {
    AcquireImage()
   })

   function Dynamsoft_OnReady() {
    DWObject = Dynamsoft.WebTwainEnv.GetWebTwain('dwtcontrolContainer');
    if (DWObject) {
      var twainsource = document.getElementById("source");
      var count = DWObject.SourceCount;
      if (count == 0) {
        twainsource.options.length = 0;
        twainsource.options.add(new Option("Looking for devices. Please wait.", 0));
      }
      else {
        for (var i = 0; i < count; i++) {
          twainsource.options.add(new Option(DWObject.GetSourceNameItems(i), i));
        }
      }
    }
}
function btnRemoveSelectedImages_onclick() {
    if (DWObject) {
      DWObject.RemoveAllSelectedImages();
    }
}

  function AcquireImage() {
    btnRemoveSelectedImages_onclick()
    if (DWObject) {
      var OnAcquireImageSuccess, OnAcquireImageFailure;
      OnAcquireImageSuccess = OnAcquireImageFailure = function () {
        DWObject.CloseSource();
      };

      DWObject.SelectSourceByIndex(document.getElementById("source").selectedIndex);
      DWObject.OpenSource();

      if (DWObject.ErrorCode != 0) {
        alert(DWObject.ErrorString);
      }
      else {
        // DWObject.PixelType = EnumDWT_PixelType.TWPT_RGB;
        DWObject.IfFeederEnabled = true;

        if (DWObject.IfFeederEnabled == true) {
          if (DWObject.IfPaperDetectable != true) {
            DWObject.IfAutoFeed = true;
            DWObject.IfDisableSourceAfterAcquire = true;
            DWObject.XferCount = -1;
            DWObject.AcquireImage();
          }
          else {
            if (DWObject.IfFeederLoaded == true) {

              DWObject.IfAutoFeed = true;
              DWObject.IfDisableSourceAfterAcquire = true;
              DWObject.XferCount = -1;
              DWObject.AcquireImage();


            }
            else {
              alert("There is no paper loaded in ADF.");
              DWObject.CloseSource();
            }
          }
        }
        else {
          DWObject.IfAutoFeed = true;
          DWObject.IfDisableSourceAfterAcquire = true;
          DWObject.XferCount = -1;
          DWObject.AcquireImage();
        }
      }
    }
  }

  function SaveImage() {
    if (DWObject) {
      DWObject.IfShowFileDialog = true;
      DWObject.SaveAllAsMultiPageTIFF("DynamicWebTWAIN.tiff", OnSuccess, OnFailure);
    }
  }

  function OnSuccess() {
    console.log('successful');
  }

  function OnFailure(errorCode, errorString) {
    alert(errorString);
  }

  function UploadImage() {
    const csrf = $('input[name="_csrf_token"]').val();

    if (DWObject) {
      // If no image in buffer, return the function
      if (DWObject.HowManyImagesInBuffer == 0) {
        alertify.error('<i class="close icon"></i>Please scan documents first.');
      }
      else {
        let batch_id = $('#batch_id').val()
        $('#batch_id').val(batch_id)
        let user_id = $('#user_id').val()

        var strHTTPServer = location.hostname;
        var CurrentPathName = unescape(location.pathname);
        var CurrentPath = CurrentPathName.substring(0, CurrentPathName.lastIndexOf("/") + 1);
        var strActionPage = "/loas/validate_accountlink_evoucher/qrcode"

        DWObject.IfSSL = Dynamsoft.Lib.detect.ssl;
        var _strPort = location.port == "" ? 80 : location.port;
        if (Dynamsoft.Lib.detect.ssl == true)
          _strPort = location.port == "" ? 443 : location.port;
        DWObject.HTTPPort = _strPort;

        var Digital = new Date();
        var uploadfilename = Digital.getMilliseconds();
        var loa_number = ""
        var error = 0

//          for (i = 0; i < DWObject.HowManyImagesInBuffer; i++) {
          DWObject.ClearAllHTTPFormField();
//            DWObject.SetHTTPFormField("user_id", user_id);
//            DWObject.SetHTTPFormField("loa_number", loa_number);

          DWObject.SetHTTPHeader("X-CSRF-TOKEN", csrf)
          DWObject.ConvertToGrayScale(0);
          DWObject.HTTPUploadThroughPost(
            strHTTPServer, 0, strActionPage,
            uploadfilename + "_" + 0 + ".jpg"
          );

          let response = JSON.parse(DWObject.HTTPPostResponseString);
          console.log(response)
          let error1 = '<div id="message" class="ui negative message"><ul class="list">'
          if (response.id == undefined) {
            $('div[id="message"]').remove()
            $('p[role="append2"]').append(error1 + `<li> ` + response.message + `</li> </ul> </div>`)
          } else {
            let member_id = response.id
            let coverage = "PEME"

            $('div[id="message"]').remove()
            swal({
              title: 'Authentication Successful',
              text: 'Proceed to Package Information',
              type: 'success',
              allowOutsideClick: false,
              confirmButtonText: '<i class="check icon"></i> Ok',
              confirmButtonClass: 'ui button primary',
              buttonsStyling: false
            }).then(function () {
              window.document.location = `/loas/${member_id}/evoucher_number/redirect_peme/${coverage}`
            }).catch(swal.noop)
          }
        }
    }
  }

  //END DYNMASOFT

  $('#peme_choose_other_options_qrcode').on('mouseover', function() {
      $('#peme_choose_other_options_qrcode').on('click', function() {
          $('div[id="peme_modal_options"]')
              .modal({
                  closable: false,
                  autofocus: false,
                  observeChanges: true
              })
              .modal('show');
        $('#peme_modal_option_qrcode').modal('hide');
      })
  })

  $('#btn_submit_evoucher').on('click', function(){
    let evoucher_number = $('#peme_evoucher').val()
    let error = '<div id="message" class="ui negative message"><ul class="list">'

    if (evoucher_number == "")
    {
      $('div[id="message"]').remove()
      $('p[role="append2"]').append(error + '<li>Please enter eVoucher Number</li> </ul> </div>')
    }
    else if(evoucher_number.length != 6)
    {
      $('div[id="message"]').remove()
      $('p[role="append2"]').append(error + '<li>Please complete eVoucher Number</li> </ul> </div>')
    }
    else
    {
      $('div[id="message"]').remove()
      let type = $('#selected_type').text()
      let evoucher_number = $('#peme_evoucher').val()
      let evoucher = `${type}-${evoucher_number}`
      $.ajax({
        url: `/loas/validate_accountlink_evoucher/${evoucher}`,
        type: 'get',
        success: function(response) {
          if (response.id == undefined) {
              if (response.message == "Member is not allow to avail PEME Reason: Member needs to encode personal information in https://memberlink-ip-ist.medilink.com.ph/en/evoucher")
              {
                $('div[id="message"]').remove()
                $('p[role="append2"]').append(error + `<li> ` + `Member is not allow to avail PEME Reason: Member needs to encode personal information in <a href="https://memberlink-ip-ist.medilink.com.ph/en/evoucher" target="_blank"> https://memberlink-ip-ist.medilink.com.ph/en/evoucher </a>` + `</li> </ul> </div>`)
              }
              else
              {
                $('div[id="message"]').remove()
                $('p[role="append2"]').append(error + `<li> ` + response.message + `</li> </ul> </div>`)
              }
          } else {
            let member_id = response.id
            let coverage = "PEME"

            $('div[id="message"]').remove()
            $('#evoucher_field').removeClass('error')
            $('#evoucher_field').find('.prompt').remove()
            swal({
              title: 'Authentication Successful',
              text: 'Proceed to Package Information',
              type: 'success',
              allowOutsideClick: false,
              confirmButtonText: '<i class="check icon"></i> Ok',
              confirmButtonClass: 'ui button primary',
              buttonsStyling: false
            }).then(function () {
              window.document.location = `/loas/${member_id}/evoucher_number/redirect_peme/${coverage}`
            }).catch(swal.noop)
          }
        }
      })
    }
  })
})

onmount('div[role="peme-loa-validation"]', function() {

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
  $('#loa_peme_confirm_no').on('click', function() {
      $('#confirmation_loa_modal').modal('hide')
  })
  $('#loa_peme_confirm_yes').on('click', function() {
      $('#loa').submit()
  })
})


onmount('form[id="validate_accountlink_member"]', function() {
    $('.peme_input').on('keypress', function(evt) {
        let theEvent = evt || window.event;
        let key = theEvent.keyCode || theEvent.which;
        key = String.fromCharCode(key);
        let regex = /[a-zA-Z,. -]/;

        if ($(this).val().length <= 1 && evt.keyCode == 32 || regex.test(key) == false) {
            return false;
        } else {
            $(this).on('focusout', function(evt) {
                $(this).val($(this).val().charAt(0).toUpperCase() + $(this).val().slice(1))
            })
        }
    })

    $('.peme_date_input').on('keypress', function(evt) {
        let theEvent = evt || window.event;
        let key = theEvent.keyCode || theEvent.which;
        key = String.fromCharCode(key);
        let regex = /[0-9,/]/;

        if ($(this).val().length <= 1 && evt.keyCode == 32 || regex.test(key) == false) {
            return false;
        } else {
            $(this).on('focusout', function(evt) {
                $(this).val($(this).val().charAt(0).toUpperCase() + $(this).val().slice(1))
            })
        }
    })


    let min_date = new Date("01-01-1900")
    let max_date = new Date("12-31-2000")
    $('div[id="birth_date"]').calendar({
        type: 'date',
        minDate: min_date,
        maxDate: max_date,
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
                return month + '/' + day + '/' + year;
            }
        }
    });

   $('input[name="radio"]').on('change', function() {
    let value = $('input[name="radio"]:checked').val()
    $('input[name="peme[gender]"]').val(value)
    $('#gender_radio').removeClass('error')
    $('#gender_radio').find('.prompt').remove()
   })

   $('#submit').on('click', function(e) {
    // $('#validate_accountlink_member').submit()
    $('#validate_accountlink_member').form({
        inline: true,
        on: 'blur',
        fields: {
            'peme[first_name]': {
                identifier: 'peme[first_name]',
                rules: [{
                  type: 'empty',
                  prompt: 'Please enter first name'
                },
                {
                  type: 'regExp',
                  value: '^[a-zA-Z,. -]+$',
                  prompt: 'Must consist of letters, dot (.) comma (,) and hypen (-) only'
                }]
            },
            'peme[last_name]': {
                identifier: 'peme[last_name]',
                rules: [{
                  type: 'empty',
                  prompt: 'Please enter last name'
                },
                {
                  type: 'regExp',
                  value: '^[a-zA-Z,. -]+$',
                  prompt: 'Must consist of letters, dot (.) comma (,) and hypen (-) only'
                }]
            },
            'peme[extension]': {
                identifier: 'peme[extension]',
                optional: true,
                rules: [{
                  type: 'regExp',
                  value: '^[a-zA-Z,. -]+$',
                  prompt: 'Must consist of letters, dot (.) comma (,) and hypen (-) only'
                }]
            },
            'peme[birth_date]': {
                identifier: 'peme[birth_date]',
                rules: [{
                  type: 'empty',
                  prompt: 'Please enter birth date'
                },
                {
                  type: 'regExp',
                  value: '^[0-9,/]+$',
                  prompt: 'Must consist of numbers, and slash (/) only'
                }]
            },
            'peme[civil_status]': {
                identifier: 'peme[civil_status]',
                rules: [{
                    type: 'empty',
                    prompt: 'Please enter civil status'
                }]
            },
            'peme[gender]': {
                identifier: 'peme[gender]',
                rules: [{
                    type: 'empty',
                    prompt: 'Please select a gender'
                }]
            }
        },
      onSuccess: function(){
        return valdiate_evoucher()
      },
      onFailure: function() {
        $(this).removeClass('error')
        return false
      }
    })
  })
})

function valdiate_evoucher() {
  let member_id = $('#member_id').val()
  let gender = $('input[name="radio"]:checked').val()
  let evoucher = $('#evoucher').val()
  let error = '<div id="message" class="ui negative message"><ul class="list">'
  let birth_date = $('input[name="peme[birth_date]"]').val()
  birth_date = new Date(birth_date);
  var today = new Date();
  var age = Math.floor((today-birth_date) / (365.25 * 24 * 60 * 60 * 1000));
  const csrf = $('a[data-to="/sign_out"]').attr('data-csrf');
  let returntf = true

  $.ajax({
    url: `/members/validate_accountlink_evoucher/${evoucher}`,
    type: 'get',
    async: false,
    success: function(response) {
      if((gender == "Male") && (response.male == true)){
        if((response.age_from <= age) && (age <= response.age_to)){
        }
        else{
          $('div[id="message"]').remove()
          $('p[role="append"]').append(error + '<li>You are not eligible to avail this e-voucher. Reason: ' + age + ' is not eligible to avail this package</li> </ul> </div>')
          returntf = false
        }
      }
      else if((gender == "Female") && (response.female == true)){
       if((response.age_from <= age) && (age <= response.age_to)){
        }
        else{
          $('div[id="message"]').remove()
          $('p[role="append"]').append(error + '<li>You are not eligible to avail this e-voucher. Reason: ' + age + ' is not eligible to avail this package</li> </ul> </div>')
          returntf = false
        }
      }
      else{
        $('div[id="message"]').remove()
        $('p[role="append"]').append(error + '<li>You are not eligible to avail this e-voucher. Reason: ' + gender + ' is not eligible to avail this package</li> </ul> </div>')
        returntf = false
      }
    }
  })
  return returntf
}

onmount('div[id="validate_member_peme', function () {

    $("#evoucher").keydown(function (e) {
        // Allow: backspace, delete, tab, escape, enter and .
        if ($.inArray(e.keyCode, [46, 8, 9, 27, 190]) !== -1 ||
             // Allow: Ctrl+A, Command+A
            (e.keyCode === 65 && (e.ctrlKey === true || e.metaKey === true)) ||
             // Allow: home, end, left, right, down, up
            (e.keyCode >= 35 && e.keyCode <= 40)) {
                 // let it happen, don't do anything
            $('div[id="message"]').remove()
            $('#evoucher_field').removeClass('error')
            $('#evoucher_field').find('.prompt').remove()
                 return;
        }
        // Ensure that it is a number and stop the keypress
        if ((e.shiftKey || (e.keyCode < 48 || e.keyCode > 57)) && (e.keyCode < 96 || e.keyCode > 105)) {
            e.preventDefault();
        }
        else if($('#evoucher').val().length != 6){
            $('div[id="message"]').remove()
            $('#evoucher_field').removeClass('error')
            $('#evoucher_field').find('.prompt').remove()
        }
    });

$('.validate_button_submit').click(function(){
    let evoucher = $('#evoucher').val()
    let error = '<div id="message" class="ui negative message"><ul class="list">'
    if(evoucher == ''){
      $('#evoucher_field').removeClass('error')
      $('#evoucher_field').find('.prompt').remove()
      $('#evoucher_field').addClass('error')
      $('#evoucher_field').append(`<div class="ui basic red pointing prompt label transition visible">Please enter e-voucher number</div>`)
    }
    else if(evoucher.length != 6){
      $('#evoucher_field').removeClass('error')
      $('#evoucher_field').find('.prompt').remove()
      $('#evoucher_field').addClass('error')
      $('#evoucher_field').append(`<div class="ui basic red pointing prompt label transition visible">Please enter a 6-digit number</div>`)
    }
    else{
      $.ajax({
        url: `/members/validate_accountlink_evoucher/${evoucher}`,
        type: 'get',
        success: function(response) {
          if (response.id == undefined) {
            $('div[id="message"]').remove()
            $('#evoucher_field').removeClass('error')
            $('#evoucher_field').find('.prompt').remove()
            $('#evoucher_field').addClass('error')
            $('#evoucher_field').append(`<div class="ui basic red pointing prompt label transition visible">` + response.message + `</div>`)
          } else {
            $('div[id="message"]').remove()
            $('#evoucher_field').removeClass('error')
            $('#evoucher_field').find('.prompt').remove()
            swal({
              title: 'Authentication Successful',
              text: 'Proceed to Pre-Employment Medical Examination Application form',
              type: 'success',
              allowOutsideClick: false,
              confirmButtonText: '<i class="check icon"></i> Ok',
              confirmButtonClass: 'ui button primary',
              buttonsStyling: false
            }).then(function () {
              window.location.href = `/members/${response.id}/validate/accountlink_member`
            }).catch(swal.noop)
          }
        }
      })
    }
  })
})


onmount('div[role="peme-loa-validation"]', function() {
  var currentLocaleData = moment.localeData();
  currentLocaleData = moment(currentLocaleData).format("YYYY-MM-DD");
  var availment_date_selector = $('input[name="loa[availment_date]"]');

  if (availment_date_selector.val() == "") {
    availment_date_selector.val(currentLocaleData);
  }

  $('div[id="availment-date"]').calendar({
    type: 'date',
    minDate: new Date(currentLocaleData),
    maxDate: new Date(currentLocaleData),
    formatter: {
      date: function date(_date, settings) {
        if (!_date) return '';
        var day = _date.getDate() + '';
        if (day.length < 2) {
          day = '0' + day;
        }
        var month = _date.getMonth() + 1 + '';
        if (month.length < 2) {
          month = '0' + month;
        }
        var year = _date.getFullYear();
        return year + '-' + month + '-' + day;
      }
    }
  });

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
          window.location.href = '/loas/cancel/peme'
      } else {
          window.location.href = 'http://paylinkapiuat.medilink.com.ph/LOA.aspx';
      }
  });

  $('#fail_close').on('click', function() {
      $('#cancel_fail_modal').modal('close');
  });

  $('#cancel_package').on('click', function() {
      if (session == "yes") {
          let lab = $('#loa_id').val()
          $.ajax({
              url: `/loas/${lab}/cancel/peme`,
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
      } else {
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

})

onmount('div[id="loa_show"]', function() {
    let date_from =  $('input[name="loa[admission_date]"]').val()
    let currentDate = new Date()

    let date_split = date_from.split("-");
    let get_date = date_split[2];
    let split_date = get_date.split(" ");
    let date = split_date[0];
    let date_val = date_split[1] -1;

    let new_date = new Date(date_split[0], date_val, date);

    $('#verify').click(function() {
      if (currentDate >= new_date) {
        $('#confirmation_peme_vloa_modal').modal('show');

        $('#loa_verify_confirm_no').on('click', function() {
            $('#confirmation_peme_vloa_modal').modal('hide')
        })

      } else {
        $('.ajs-message.ajs-error.ajs-visible').remove()
        alertify.error('<i class="close icon"></i>Please verify within scheduled<br>PEME date.');
      }
    })
})
