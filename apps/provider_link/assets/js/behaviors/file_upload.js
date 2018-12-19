onmount('div[id="fileUpload"]', function () {
  $('#imageUpload').on('change', function(){
    $('.ui.negative.message').remove()
  });

  $('#file_submit').on('click', function(){
    if($("#id_type").val() == ""){
      $('.ajs-message.ajs-error.ajs-visible').remove()
      $("#scan").addClass('error')
      $('#scan').append(`<div class="ui basic red pointing prompt label transition visible">Please select ID Type</div>`)
    } else if($('#imageUploadCard').val() == ""){
      $('.ajs-message.ajs-error.ajs-visible').remove()
       alertify.error('Please upload or scan ID<i id="notification_error" class="close icon"></i>');
    }
    else
    {
      $('#request_acu').submit()
    }
  });

  $('#id_type').on('change', function(){
    $('#scan').removeClass('error')
    $('#scan').find('.prompt').remove()
  })

	// $('#imageRemove').on('click', function(){
	// 	$("#photo").css("background-image", "none");
 //    $("#photo").removeAttr('style');
 //   	$("#photo").attr('src', '/images/file-upload.png');
 //    $("#imageLabel").html('<i class="folder open icon"></i> Browse Photo');
	// });

	$.uploadPreview({
	    input_field: "#imageUpload",
	    preview_box: "#photo",
	    label_field: "#imageLabel"
	});
});

(function ($) {
  $.extend({
    uploadPreview : function (options) {

      // Options + Defaults
      var settings = $.extend({
        input_field: ".image-input",
        preview_box: ".image-preview",
        label_field: ".image-label",
        label_default: " Browse Photo",
        label_selected: " Change Photo",
        no_label: false,
        success_callback : null,
      }, options);

      // Check if FileReader is available
      if (window.File && window.FileList && window.FileReader) {
        if (typeof($(settings.input_field)) !== 'undefined' && $(settings.input_field) !== null) {
          $(settings.input_field).change(function() {
            var files = this.files;
            if (files.length > 0) {
              var file = files[0];
              var photo = URL.createObjectURL(event.target.files[0]);
              var reader = new FileReader();

              // Load file
              reader.addEventListener("load",function(event) {
                var loadedFile = event.target;
                let size = file.size <= 1024 * 1024 * 5
                // var photo = URL.createObjectURL(loadedFile);

                // Check format
                var ValidImageTypes = ['image/jpg', 'image/jpeg', 'image/png'];
                if ($.inArray(file.type, ValidImageTypes) > -1) {
                  // Image
                  if (size) {
                    $(settings.preview_box).css("background-image", "url("+photo+")");
                    $(settings.preview_box).attr('src', '');
                    $(settings.preview_box).css("background-size", "cover");
                    $(settings.preview_box).css("background-position", "center center");
                    $(settings.preview_box).css("height", "300px");
                    $(settings.preview_box).css("width", "auto");
                  } else {
                    $('input[name="photo_params[photo]"]').val("")
                    $("#photo").css("background-image", "none");
                    $("#photo").attr('src', '/images/file-upload.png');
                    $('#photo').css("height", "240px");
                    $('#photo').css("width", "290px");
                    $("#imageLabel").html('<i class="folder open icon"></i> Browse Photo');
                    $('.ajs-message.ajs-error.ajs-visible').remove()
                    alertify.error('<i class="close icon"></i> Maximum file size is 5MB')
                  }
                }
                else {
                  $('input[name="photo_params[photo]"]').val("")
                  $('.ajs-message.ajs-error.ajs-visible').remove()
                  alertify.error('<i class="close icon"></i> Acceptable file types are jpg, jpeg and png.')
                }
              });

              if (settings.no_label == false) {
                // Change label
                $(settings.label_field).html('<i class="refresh icon"></i>' + settings.label_selected);
              }

              // Read the file
              reader.readAsDataURL(file);

              // Success callback function call
              if(settings.success_callback) {
                settings.success_callback();
              }
            } else {
              if (settings.no_label == false) {
                // Change label
                $(settings.label_field).html('<i class="folder open icon"></i>' + settings.label_default);
              }

              // Clear background
              // $(settings.preview_box).css("background-image", "none");
              // $(settings.preview_box).attr('src', '/images/file-upload (1).png');

            }
          });
        }
      } else {
          alert("You need a browser with file reader support, to use this form properly.");
          return false;
      }
    }
  });
})(jQuery);
