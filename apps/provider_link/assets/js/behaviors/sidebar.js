let pgurl = window.location.href;

$(".sidebar a.item").each(function() {
  if (window.location.pathname == "/") {
    $('#home').addClass("active");
  } else {
    if (pgurl.indexOf($(this).attr("id")) > -1) {
      $(this).addClass("active");
    }
  }

});
