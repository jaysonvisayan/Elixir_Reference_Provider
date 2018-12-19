
onmount('div[id="acu_schedule_member"]', function() {
  $('.ajs-message.ajs-error.ajs-visible').remove()
  $('#upload_member').on('click', function() {
    $('#icon').hide()
    $('#success').hide()
    if($('#reupload').val() == "No"){
      $('#upload_modal').modal({
        closable: false,
        autofocus: false,
        observeChanges: true,
        transition: 'fade right',
        onHide: function() {
        $('#select').html('')
        $('#dl').html('')
        $('#upload').val('')
        // $('.progress-bar').css("width", "0%");
      }
      }).modal("show")
    }
    else{
     $('#reupload_modal').modal({
        closable: false,
        autofocus: false,
        observeChanges: true,
        transition: 'fade right'
      }).modal("show")
    }
  })

  $('#reupload_member').on('click', function() {
    $('#reupload_modal').modal('close')
    $('#upload_modal').modal({
      closable: false,
      autofocus: false,
      observeChanges: true,
      transition: 'fade right',
      onHide: function() {
        $('#select').html('')
        $('#dl').html('')
        $('#upload').val('')
        // $('.progress-bar').css("width", "0%");
      }
    }).modal("show")
  })

  $('#proceed').on('click', function() {
    if($('#upload').val() == ""){
      alert_error("Please select a file to be uploaded.")
    }
    else{
    var file = $('#upload')[0].files[0];
    var upload = new Upload(file);

    upload.doUpload();
}
})

  $('#next').on('click', function() {
    if($('#hidden_acu').val() == ""){
      alert_error("Please select at least (1) one member.")
    }
    else{
      $('#next').removeAttr('type')
    }
  })

  let counter = 1

  $('#upload').on('change', function(){
    $('.ajs-message.ajs-error.ajs-visible').remove()
    let icon = 'file outline'
    let file_name = $(this)[0].files[0].name
    if ($(this).val() != '') {
      let file_size = $(this)[0].files[0].size
      if((file_name).indexOf('.csv') >= 0){
        if(file_size <= 5242880) {
        } else {
          $(this).val('')
          alertify.error('<i class="close icon"></i>Maximum file size is 5 megabytes')
        }
      } else {
        $(this).val('')
        alertify.error('<i class="close icon"></i>Only .csv file format must be accepted')
      }
    }
  })

  $(document).on('click', 'a[class="download"]', function() {
    const csrf = $('input[name="_csrf_token"]').val();
    let log_id = $(this).attr("asm_upload_logs_id")
    let file = $(this).attr("file_name")
    let account_code = $('#account_code').val()
    let batch_no = $('#batch_no').val()
    let utc = new Date()
    let date = moment(utc)
    date = date.format("MM/DD/YYYY")

    $.ajax({
      url:`/acu_schedules/${log_id}/download_member`,
      headers: {"X-CSRF-TOKEN": csrf},
      type: 'get',
      dataType: 'json',
      success: function(response){
        let filename =  batch_no + '-' + account_code + '-' + date +'.csv'
        downloadCSV(response, filename);
      }
    });

  });

})

  function downloadCSV(csv, filename) {
    let csvFile;
    let downloadLink;

    // CSV file
    csvFile = new Blob([csv], {type: "text/csv"});

    // Download link
    downloadLink = document.createElement("a");

    // File name
    downloadLink.download = filename;

    // Create a link to the file
    downloadLink.href = window.URL.createObjectURL(csvFile);

    // Hide download link
    downloadLink.style.display = "none";

    // Add the link to DOM
    document.body.appendChild(downloadLink);

    // Click download link
    downloadLink.click();
  }

  function alert_error(message){
    $('.ajs-message.ajs-error.ajs-visible').remove()
    alertify.error(message + '<i id="notification_error" class="close icon"></i>');
    alertify.defaults = {
      notifier:{
        delay:5,
        position:'top-right',
        closeButton: false
      }
    };
  }

  var Upload = function (file) {
    this.file = file;
  };

  Upload.prototype.getType = function() {
      return this.file.type;
  };
  Upload.prototype.getSize = function() {
      return this.file.size;
  };
  Upload.prototype.getName = function() {
      return this.file.name;
  };
  Upload.prototype.doUpload = function () {
      var that = this;
      var formData = new FormData();

      // add assoc key values, this will be posts values
      formData.append("file", this.file, this.getName());
      formData.append("id", $('#as_id').val());
      const csrf = $('input[name="_csrf_token"]').val();
      $('#overlay').css("display", "block")
      $.ajax({
          type: "POST",
          url: "/acu_schedules/upload_member",
          headers: {"X-CSRF-TOKEN": csrf},
          // xhr: function () {
          //     var myXhr = $.ajaxSettings.xhr();
          //     if (myXhr.upload) {
          //         myXhr.upload.addEventListener('progress', that.progressHandling, false);
          //     }
          //     return myXhr;
          // },
          success: function (data) {
            if(data.id == undefined){
              $('#overlay').css("display", "none");
              $('#icon').hide()
              $('#success').hide()
              $('#dl').html('')
              alert_error(data.message)
            }
            else{
            var valArray = []
            $('input:checkbox').attr('checked', false);
            for (let card_no of data.card_nos) {
              $(`input:checkbox[card_no="${card_no}"]`).prop( "checked", true );
              valArray.push($(`input:checkbox[card_no="${card_no}"]`).val())
            }
              $('input[name="acu_schedule_member[acu_schedule_member_ids_main]"]').val(valArray)
              $('#selected_members').html(valArray.length)
              $('#icon').show()
              $('#success').show()
              $('#select').html(data.message)
              $('#dl').html(`<a class='download' style='cursor: pointer' asm_upload_logs_id='${data.id}'' file_name='${data.filename}'>Download Result</a>`)
              $('#result').html(`<a class='download' style='cursor: pointer' asm_upload_logs_id='${data.id}'' file_name='${data.filename}'>Download Result</a>`)
              $('#overlay').css("display", "none");
          }
        },
          error: function (error) {
              // handle error
          },
          async: true,
          data: formData,
          cache: false,
          contentType: false,
          processData: false
          // timeout: 60000
      });
  };

  // Upload.prototype.progressHandling = function (event) {
  //     var percent = 0;
  //     var position = event.loaded || event.position;
  //     var total = event.total;
  //     var progress_bar_id = "#progress-wrp";
  //     if (event.lengthComputable) {
  //         percent = Math.ceil(position / total * 100);
  //     }
  //     // update progressbars classes so it fits your code
  //     $(progress_bar_id + " .progress-bar").css("width", +percent + "%");
  //     if(percent != 100){
  //     $(" .status").text(percent + "% done");
  //     }
  //     else{
  //      $(" .status").text("Update Successful");
  //     }
  // };
