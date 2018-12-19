$('#capture').on('click', function(){
    var video;
    var webcamStream;
    var video = document.getElementById('video');
    var canvas = document.getElementById('canvas');
    var photo = document.getElementById('gov_photo');
    var track;

    function clearphoto() {
      var context = canvas.getContext('2d');
      context.fillStyle = "#FFF";
      context.fillRect(0, 0, canvas.width, canvas.height);

      var data = canvas.toDataURL('image/png');
      photo.setAttribute('src', data);
    }

    navigator.mediaDevices.getUserMedia({ video: true, audio: false })
      .then(function(stream) {
          video.srcObject = stream;
          track = stream.getTracks()[0];
          video.play();
      })
      .catch(function(err) {
          console.log("An error occurred! " + err);
    });

    $('#take_image').on('click', function() {
      var context = canvas.getContext('2d');
      canvas.width = 320;
      canvas.height = 240;
      context.drawImage(video, 0, 0, 320, 240);

      var data = canvas.toDataURL('image/png');
      $('#gov_photo').attr('src', data);
      $('#photo-web-cam').val(data)
      $('p[role="append_new_capture"]').empty()

    })

    $('#submit_capture').on('click', function(e) {
      if($('#photo-web-cam').val() == ""){
        let error = '<div id="message" class="ui negative message"><ul class="list">'
        $('div[id="message"]').remove()
        $('p[role="append_new_capture"]').append(error + '<li>Please take a photo.</li> </ul> </div>')
        e.preventDefault()
      } else {
        track.stop();
        $('#goverment_id_capture').val("yes")
        $('div[id = "modal_facial_capture"]').attr('class', 'ui tiny modal');
        $('div[id ="modal_facial_capture"]').modal({
          closeable: false,
          autofocus: false,
          observeChanges: true
          }).modal('show');
          $('p[role="append_new_capture"]').empty()
      }
    })

    $('.close.icon').on('click', function() {
      track.stop();
      clearphoto();
    })
})

$('#submit_ID').on('click', function(){
  var video;
  var webcamStream;
  var video = document.getElementById('video2');
  var canvas = document.getElementById('canvas2');
  var photo = document.getElementById('photo');
  var track;

  function clearphoto() {
    var context = canvas.getContext('2d');
    context.fillStyle = "#FFF";
    context.fillRect(0, 0, canvas.width, canvas.height);

    var data = canvas.toDataURL('image/png');
    photo.setAttribute('src', data);
  }

  navigator.mediaDevices.getUserMedia({ video: true, audio: false })
    .then(function(stream) {
        video.srcObject = stream;
        track = stream.getTracks()[0];
        video.play();
    })
    .catch(function(err) {
        console.log("An error occurred! " + err);
  });

  $('#take_image2').on('click', function() {
    var context = canvas.getContext('2d');
    canvas.width = 320;
    canvas.height = 240;
    context.drawImage(video, 0, 0, 320, 240);

    var data = canvas.toDataURL('image/png');
    $('#photo').attr('src', data);
    $('#facial-web-cam').val(data)
    $('p[role="append_new_capture"]').empty()

  })

  $('#submit_capture2').on('click', function() {
    if($('#facial-web-cam').val() == ""){
      let error = '<div id="message" class="ui negative message"><ul class="list">'
      $('div[id="message"]').remove()
      $('p[role="append_new_capture"]').append(error + '<li>Please take a photo.</li> </ul> </div>')
      e.preventDefault()
    } else {
      track.stop();
      $('#fc-photo').submit()
    }
  })

  $('.close.icon').on('click', function() {
    track.stop();
    clearphoto();
  })
})

$('#submit_capture').on('click', function(){
  var video;
  var webcamStream;
  var video = document.getElementById('video2');
  var canvas = document.getElementById('canvas2');
  var photo = document.getElementById('photo');
  var track;

  function clearphoto() {
    var context = canvas.getContext('2d');
    context.fillStyle = "#FFF";
    context.fillRect(0, 0, canvas.width, canvas.height);

    var data = canvas.toDataURL('image/png');
    photo.setAttribute('src', data);
  }

  navigator.mediaDevices.getUserMedia({ video: true, audio: false })
    .then(function(stream) {
        video.srcObject = stream;
        track = stream.getTracks()[0];
        video.play();
    })
    .catch(function(err) {
        console.log("An error occurred! " + err);
  });

  $('#take_image2').on('click', function() {
    var context = canvas.getContext('2d');
    canvas.width = 320;
    canvas.height = 240;
    context.drawImage(video, 0, 0, 320, 240);

    var data = canvas.toDataURL('image/png');
    $('#photo').attr('src', data);
    $('#facial-web-cam').val(data)
    $('p[role="append_new_capture"]').empty()

  })

  $('#submit_capture2').on('click', function() {
    if($('#facial-web-cam').val() == ""){
      let error = '<div id="message" class="ui negative message"><ul class="list">'
      $('div[id="message"]').remove()
      $('p[role="append_new_capture"]').append(error + '<li>Please take a photo.</li> </ul> </div>')
      e.preventDefault()
    } else {
      track.stop();
      $('#fc-photo').submit()
    }
  })

  $('.close.icon').on('click', function() {
    track.stop();
    clearphoto();
  })
})

$('#submit_security').on('click', function(){
  var video;
  var webcamStream;
  var video = document.getElementById('video2');
  var canvas = document.getElementById('canvas2');
  var photo = document.getElementById('photo');
  var track;

  function clearphoto() {
    var context = canvas.getContext('2d');
    context.fillStyle = "#FFF";
    context.fillRect(0, 0, canvas.width, canvas.height);

    var data = canvas.toDataURL('image/png');
   photo.setAttribute('src', data);
  }

  navigator.mediaDevices.getUserMedia({ video: true, audio: false })
    .then(function(stream) {
        video.srcObject = stream;
        track = stream.getTracks()[0];
        video.play();
    })
    .catch(function(err) {
        console.log("An error occurred! " + err);
  });

  $('#take_image2').on('click', function() {
    var context = canvas.getContext('2d');
    canvas.width = 320;
    canvas.height = 240;
    context.drawImage(video, 0, 0, 320, 240);

    var data = canvas.toDataURL('image/png');
    $('#photo').attr('src', data);
    $('#facial-web-cam').val(data)
    $('p[role="append_new_capture"]').empty()

  })

  $('#submit_capture2').on('click', function() {
    if($('#facial-web-cam').val() == ""){
      let error = '<div id="message" class="ui negative message"><ul class="list">'
      $('div[id="message"]').remove()
      $('p[role="append_new_capture"]').append(error + '<li>Please take a photo.</li> </ul> </div>')
      e.preventDefault()
    } else {
      track.stop();
      $('#fc-photo').submit()
    }
  })

  $('.close.icon').on('click', function() {
    track.stop();
    clearphoto();
  })
})
