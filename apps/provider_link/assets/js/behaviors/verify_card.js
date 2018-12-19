import {principal, dependent, submit_security} from "./acu.js"

onmount('div[id="modal_card_no_eligibility"]', function() {

  // Modal Show
  $('#choose_option_card').on('mouseover', function() {
    $('#choose_option_card').on('click', function() {
      $('div[id="modal_card_no_eligibility"]').modal({
        closable: false,
        autofocus: false,
        observeChanges: true,
        onShow: function() {
          $('#first_digit').val("")
          $('#second_digit').val("")
          $('#third_digit').val("")
          $('#fourth_digit').val("")
          $('input[id="birthdate"]').val("")
          $('div[id="message"]').remove()
          $('#birthdate_datepicker').calendar({
            type: 'date',
            maxDate: new Date(),
            popupOptions: {
                position: 'right center',
                prefer: 'opposite',
                hideOnScroll: false
            },
            inline: false,
            formatter: {
              date: function(date, settings) {
                if (!date) return ''
                var day = date.getDate() + ''
                if (day.length < 2) {
                    day = '0' + day
                }
                var month = (date.getMonth() + 1) + ''
                if (month.length < 2) {
                    month = '0' + month
                }
                var year = date.getFullYear()
                return year + '-' + month + '-' + day
              }
            }
          })
        }
      }).modal('show')
    })
  })

  // Verify Member
  $('#validate').on('click', function() {
    let cardno1 = $('input[name="card_no1"]').val()
    let cardno2 = $('input[name="card_no2"]').val()
    let cardno3 = $('input[name="card_no3"]').val()
    let cardno4 = $('input[name="card_no4"]').val()
    let card = cardno1 + cardno2 + cardno3 + cardno4
    let bdate = $('input[id="birthdate"]').val()
    let error = '<div id="message" class="ui negative message"><ul class="list">'
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

    $('#card').val(card)

    $('div[id="message"]').remove()
    if ($('#card').val() == "" && (bdate == "" || bdate == null)) {
        $('p[role="append"]').append(error + '<li>Please enter card number and birthdate.</li> </ul> </div>')
    } else if ($('#card').val() == "") {
        $('p[role="append"]').append(error + '<li>Please enter card number.</li> </ul> </div>')
    } else if (bdate == "" || bdate == null) {
        $('p[role="append"]').append(error + '<li>Please enter birthdate.</li> </ul> </div>')
    } else {
      $('#overlay').css("display", "block")
      $.ajax({
        url: `/loas/card/${card}/with_loa_validation/${bdate}/ACU`,
        type: 'get',
        success: function(response) {
          $('div[id="message"]').remove()
          $('#overlay').css("display", "none")

          if (response.type == undefined) {
            if (response.message == "Member not found") {
                  $('p[role="append"]').append(error + '<li>Please enter valid card number/birthdate to avail ACU.</li> </ul> </div>')
            } else if (response.message == "Member is not active") {
                $('p[role="append"]').append(error + '<li>Member status must be Active to avail ACU.</li> </ul> </div>')
            } else if (response.message == "Member not eligible") {
                $('p[role="append"]').append(error + '<li>Member status must be Active to avail ACU.</li> </ul> </div>')
            } else if (response.message == "Invalid Input") {
                $('p[role="append"]').append(error + '<li>Invalid Input.</li> </ul> </div>')
            } else if (response.message == "Invalid Birth Date") {
                $('p[role="append"]').append(error + '<li>Invalid Birth Date.</li> </ul> </div>')
            } else if (response.message == "No package facility rate setup.") {
                $('p[role="append"]').append(error + '<li>Cannot avail ACU. Reason: Facility has no package facility rate setup.</li> </ul> </div>')
            } else if (response.message == "You have no benefit for this coverage") {
                $('p[role="append"]').append(error + '<li>Member is not eligible to avail any ACU package.</li> </ul> </div>')
            } else if (response.message == "Facility code not found") {
                $('p[role="append"]').append(error + '<li>Facility code not found</li> </ul> </div>')
            } else if (response.message == "coverage name is not included in member product/s") {
                $('p[role="append"]').append(error + '<li>ACU not included in member product/s</li> </ul> </div>')
            } else if (response.message == "Please enter card number") {
                $('p[role="append"]').append(error + '<li>Member has no Card Number</li> </ul> </div>')
            } else if (response.message == "You are no longer valid to request ACU. Reason: Member has no benefit.") {
                $('p[role="append"]').append(error + '<li>Member is not eligible to avail any ACU package.</li> </ul> </div>')
            } else if (response.message == "Member is no longer valid to request ACU. Reason: Member has no benefit.") {
                $('p[role="append"]').append(error + '<li>Member is not eligible to avail any ACU package.</li> </ul> </div>')
            } else if (response.message == "Member is not eligible to avail ACU. Reason: Member's ACU package is not available in this facility.") {
                $('p[role="append"]').append(error + "<li>Member's ACU package is not available in this facility</li> </ul> </div>")
            } else if (response.message == "Member is not eligible to avail ACU. Reason: Package is not available in this facility.") {
                $('p[role="append"]').append(error + "<li>Member's ACU package is not available in this facility</li> </ul> </div>")
            } else if (response.message == "The Card number you have entered is invalid") {
                $('p[role="append"]').append(error + "<li>Please enter valid card number/birthdate to avail ACU.</li> </ul> </div>")
            } else if (response.message == "The Card number or birth date you have entered is invalid.") {
                $('p[role="append"]').append(error + "<li>Please enter valid card number/birthdate to avail ACU.</li> </ul> </div>")
            } else {
                $('p[role="append"]').append(error + `<li>${response.message}</li> </ul> </div>`)
            }
          }
          else{
            $('#modal_facial_capture').find('input[id="hidden-card-no"]').val(response.card_no)
            if (response.attempts < 3){
              $('#memberID').val(response.card_no)
              if ((response.type.toLowerCase() == "principal") || (response.type.toLowerCase() == "Guardian")) {
                principal(response)
              } else if (response.type.toLowerCase() == "dependent") {
                dependent(response)
              }
              $('#submit_security').on('click', function() {
                submit_security(response, "card_no_bdate")
              })
              $('div[id="modal_selection"]').modal({
                closable: false,
                autofocus: false,
                observeChanges: true,
                transition: 'fade right'
              }).modal("show");
            }else{
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
                    $("#imageLabel").html('<i class="folder open icon"></i> Browse Photo');
                    $('#photo').attr('src', '/images/file-upload.png')
                    $('#photo').attr('style', 'background-image: none; height: 240px; width: 290px;')
            }
          }
        }
      })
    }
  })

})
