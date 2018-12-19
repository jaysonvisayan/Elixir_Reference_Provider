onmount('div[id="acu_mobile"]', function() {

  const csrf = $('input[name="_csrf_token"]').val();
  let user_ids = []
  let files = []

  $('.valid_timezone').each(function(){
    let val = $(this).text()
    $(this).text(moment(val).format("MMMM DD, YYYY hh:mm A"));
  })

  jQuery.fn.dataTableExt.oSort['uk_date-pre']  = function(a) {
      a = a.slice(0, -2) + ' ' + a.slice(-2);
      var date = Date.parse(a);
      return typeof date === 'number' ? date : -1;
  }
  jQuery.fn.dataTableExt.oSort['uk_date-asc']  = function(a,b) {
      return ((a < b) ? -1 : ((a > b) ? 1 : 0));
  }
  jQuery.fn.dataTableExt.oSort['uk_date-desc'] = function(a,b) {
      return ((a < b) ? 1 : ((a > b) ? -1 : 0));
  }

  $('#acu_schedule_table').DataTable({
    aoColumns: [
      { "bSortable": false },
      null,
      null,
      null,
      null,
      null,
      null,
      { sType: 'uk_date' },
      null
    ],
    order: [[7, 'desc' ]]
  })

  $('#acu_schedule_table').on('mouseover', function () {
    $('#acu_schedule_table').find('tbody').find('tr').find('input[type="checkbox"]').unbind('change').change(function(){
      var table = $('#acu_schedule_table').DataTable()
      var rows = table.rows({ 'search': 'applied' }).nodes();

      $('input[type="checkbox"]', rows).each(function() {
        $(this).prop('checked', false)
      })

      $(this).prop('checked', true)

      let value = $(this).val()
      let check = $(this).attr("checked")
      let created_date = $(this).closest('td').closest('tr').find('.valid_timezone').text()
      value = `{"id": "${value}", "datetime": "${created_date}"}`

      if(user_ids.includes(value)){
        user_ids.length = 0
        $(this).prop('checked', false)
      }

      if($(this).is(":checked")){
        user_ids.length = 0
        user_ids.push(value)
      } else {
        user_ids.length = 0
      }
    })
  })

  $('#export_btn').on('click', function(){
    if (user_ids.length){
      const csrf = $('input[name="_csrf_token"]').val();

      $.ajax({
        url:`/acu_schedules/${user_ids}/export_member_details`,
        headers: {"X-CSRF-TOKEN": csrf},
        type: 'get',
        dataType: 'json',
        success: function(response){
          downloadCSV(response.data, response.filename);
          window.location.assign(`/acu_schedules/${user_ids}/export`)
        }
      })
    }
    else{
      swal({
        title: 'Please select batch first',
        type: 'error',
        allowOutsideClick: false,
        confirmButtonText: '<i class="check icon"></i> Ok',
        confirmButtonClass: 'ui button primary',
        buttonsStyling: false
      }).then(function () {}).catch(swal.noop)
    }
  })

})


  function downloadCSV(csv, filename) {
    let csvFile;
    let downloadLink;

    csvFile = new Blob([csv], {type: "text/csv"});

    downloadLink = document.createElement("a");

    downloadLink.download = filename;

    downloadLink.href = window.URL.createObjectURL(csvFile);

    downloadLink.style.display = "none";

    document.body.appendChild(downloadLink);

    downloadLink.click();
  }
