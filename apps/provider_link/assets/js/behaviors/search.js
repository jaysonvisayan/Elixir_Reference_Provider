function loadDataTable() {
  $('table[role="loa_table"]').dataTable({
	  	dom:
			"<'ui grid'"+
				"<'row'"+
					"<'eight wide column'l>"+
					"<'right aligned eight wide column'f>"+
				">"+
				"<'row dt-table'"+
					"<'sixteen wide column'tr>"+
				">"+
				"<'row'"+
					"<'seven wide column'i>"+
					"<'right aligned nine wide column'p>"+
				">"+
			">",
		renderer: 'semanticUI',
		pagingType: "full_numbers",
		language: {
			emptyTable:     "No Records Found!",
			zeroRecords:    "No Matching Records Found!",
			search:         "Search",
			paginate: {
				first: "<i class='angle single left icon'></i> First",
				previous: "<i class='angle double left icon'></i> Previous",
				next: "Next <i class='angle double right icon'></i>",
				last: "Last <i class='angle single right icon'></i>"
			}
    },
    searching: false,
    "lengthMenu": [[5, 10, 25, 50, -1], [5, 10, 25, 50, "All"]]
  });
}

onmount('table[role="loa_table"]', function () {
  loadDataTable();
});

onmount('div[id="loa_consult_search"]', function(){
  var table =
    $('#tbl_consult').dataTable({
	  	dom:
			"<'ui grid'"+
				"<'row'"+
					"<'eight wide column'l>"+
					"<'right aligned eight wide column'f>"+
				">"+
				"<'row dt-table'"+
					"<'sixteen wide column'tr>"+
				">"+
				"<'row'"+
					"<'seven wide column'i>"+
					"<'right aligned nine wide column'p>"+
				">"+
			">",
		renderer: 'semanticUI',
		pagingType: "full_numbers",
		language: {
			emptyTable:     "No Records Found!",
			zeroRecords:    "No Matching Records Found!",
			search:         "Search",
			paginate: {
				first: "<i class='angle single left icon'></i> First",
				previous: "<i class='angle double left icon'></i> Previous",
				next: "Next <i class='angle double right icon'></i>",
				last: "Last <i class='angle single right icon'></i>"
			}
    },
    searching: false,
    "lengthMenu": [[5, 10, 25, 50, -1], [5, 10, 25, 50, "All"]],
    'columnDefs':[
      {
        'targets': 1,
        'createdCell': function (td, cellData, rowData, row, col) {
          $(td).attr('class', 'bold');
        }
      },
      {
        'targets': 6,
        'createdCell': function (td, cellData, rowData, row, col) {
          $(td).attr('class', 'bold');
        }
      }
    ]
  });
  $('div[id="btn_search_consult"]').click(function () {

    let csrf = $('input[name="_csrf_token"]').val();
    let params = {
      loa_no: $('input[id="loa_no_consult"]').val(),
      start_date: $('input[id="start_date_consult"]').val(),
      end_date: $('input[id="end_date_consult"]').val(),
      card_no: $('input[id="card_no_consult"]').val(),
      birth_date: $('input[id="birth_date_consult"]').val(),
    }

    $.ajax({
      url: `/loas/search/consult`,
      headers: {"X-CSRF-TOKEN": csrf},
      data: {search: params},
      type: 'GET',
      success: function(response){
        table.fnClearTable();
        $.each(response.loas, function(i, consult){
          let status_class = "";
          let status = "";
          let transaction_redirect = "";
          if (consult.status.toLowerCase() == "draft"){
            transaction_redirect = "loas/" + consult.id + "/request/consult"
          }else{
            transaction_redirect = "loas/" + consult.id + "/show_consult"
          }
          if(consult.status == "") {
            status_class = "tag tag--blue";
            status = "draft";
          } else if(consult.status.toLowerCase() == null) {
            status_class = "tag tag--blue";
            status = "draft";
          } else if(consult.status.toLowerCase() == "draft") {
            status_class = "tag tag--blue";
            status = "draft";
          } else if(consult.status.toLowerCase() == "pending") {
            status_class = "tag tag--orange";
            status = "pending";
          } else if(consult.status.toLowerCase() == "approved") {
            status_class = "tag tag--green";
            status = "approved";
          } else if(consult.status.toLowerCase() == "cancelled") {
            status_class = "tag tag--black";
            status = "cancelled";
          } else if(consult.status.toLowerCase() == "disapproved") {
            status_class = "tag tag--red";
            status = "disapproved";
          } else if(consult.status.toLowerCase() == "requested") {
            status_class = "tag tag--red";
            status = "requested";
          } else if(consult.status.toLowerCase() == "for approval") {
            status_class = "tag tag--orange";
            status = "for approval";
          } else if(consult.status.toLowerCase() == "availed") {
            status_class = "tag tag--green";
            status = "availed";
          }
          let input_check = ""
          if (consult.status.toLowerCase() == "approved" && consult.is_cart == false && consult.is_batch == false){
            input_check = `<input style="width:20px; height:20px" type="checkbox" class="selection" value="${consult.id}" id="consult_loa_ids">`
          }else{
            input_check = `<input style="width:20px; height:20px" type="checkbox" id="consult_loa_ids" class="selection" value="" disabled >`
          }
          let payor = ""
          if (consult.payor != null){
            payor = consult.payor.name
          }
          let transaction_id = ""
          if (consult.transaction_id != null){
            transaction_id = consult.transaction_id
          }
          let gender = "N/A"
          if (consult.gender != null){
            gender = consult.gender
          }
          let data1 = "<a href='" + transaction_redirect + "'>" + transaction_id + "</a>"
          let data2 = "<div>Card No.: " + consult.card.member.card_number  + "</div>"
          + "<div>Age: " + consult.card.member.age + "</div>"
          + "<div>Gender: " + gender + "</div>"
          let data3 = payor
          let data4 = consult.issue_date
          let data5 = consult.total_amount
          let data6 = "<div class='" + status_class + "'>"
          + status + "</div>"
          let data7 = consult.loa_number
          table.fnAddData([input_check,
                        data1,
                        data2,
                        data3,
                        data4,
                        data5,
                        data6,
                        data7]);

        })
        // table.destroy();
        // $("#tbl_consult").remove();

        // var table =
        //   "<table class='ui celled table big-table big-table' role='loa_table' id='tbl_consult' >"
        //   + "<thead>"
        //   + "<tr>"
        //   + "<td class='bold dim'>TRANSACTION ID</td>"
        //   + "<td class='bold dim'>MEMBER INFORMATION</td>"
        //   + "<td class='bold dim'>PAYOR</td>"
        //   + "<td class='bold dim'>ISSUED DATE/TIME</td>"
        //   + "<td class='bold dim'>AMOUNT</td>"
        //   + "<td class='bold dim'>STATUS</td>"
        //   + "<td class='bold dim'>LOA NUMBER</td>"
        //   // + "<td></td>"
        //   + "</tr>"
        //   + "</thead>"
        //   + "<tbody>"
        // var data = ""

        // if (response.loas.length == 0){
        // }
        // else {

        //   $.each(response.loas, function(i,consult){
        //     let status_class = "";
        //     let status = "";
        //     let consult_redirect = '';

        //     if(consult.status == "draft" || consult.status == "" || consult.status == null){
        //       status_class = "tag tag--blue";
        //       status = "draft";
        //       consult_redirect = 'loas/' + consult.id + '/request/consult';
        //     } else if(consult.status == "pending") {
        //       status_class = "tag tag--orange";
        //       status = "pending";
        //       consult_redirect = 'loas/' + consult.id + '/show_consult';
        //     } else if(consult.status == "approved") {
        //       status_class = "tag tag--green";
        //       status = "approved";
        //       consult_redirect = 'loas/' + consult.id + '/show_consult';
        //     } else if(consult.status == "cancelled") {
        //       status_class = "tag tag--black";
        //       status = "cancelled";
        //       consult_redirect = 'loas/' + consult.id + '/show_consult';
        //     } else if(consult.status == "disapproved") {
        //       status_class = "tag tag--red";
        //       status = "disapproved";
        //       consult_redirect = 'loas/' + consult.id + '/show_consult';
        //     } else if(consult.status == "for approval") {
        //       status_class = "tag tag--orange";
        //       status = "for approval";
        //       consult_redirect = 'loas/' + consult.id + '/show_consult';
        //     }


        //     data = data
        //       + "<tr>"
        //       + "<td class='bold'><a href='" + consult_redirect + "'>" + consult.transaction_id + "</td></a>"
        //       + "<td>"
        //       + "<div>Card No.: " + consult.card.number + "</div>"
        //       // + "<div>Member Name: " + consult.card.member.name + "</div>"
        //       + "<div>Age: " + consult.card.member.age + "</div>"
        //       // + "<div>Birth Date: " + consult.card.member.birth_date + "</div>"
        //       + "<div>Gender: " + consult.card.member.gender + "</div>"
        //       + "</td>"
        //       + "<td>" + "Maxicare" + "</td>"
        //       + "<td>" + consult.issue_date + "</td>"
        //       + "<td class='bold'>" + consult.total_amount + "</td>"
        //       + "<td>"
        //       + "<div class='" + status_class + "'>"
        //       + status + "</div>"
        //       + "</td>"
        //       + "<td>" + consult.loa_number + "</td>"
        //       // + "<td><a href=''><span class='mobile-only mr-1'> Download </span><img src='images/table_row_download.png' alt=''></a></td>"
        //      + "</tr>"
        //   });

        // }

        // $('div[id="div_consult"]').html(table + data + "</tbody></table>");
        // loadDataTable();
      }
    });

  });

});

onmount('div[id="loa_lab_search"]', function(){

  $('div[id="btn_search_lab"]').click(function () {

    let csrf = $('input[name="_csrf_token"]').val();
    let params = {
      loa_no: $('input[id="loa_no_lab"]').val(),
      start_date: $('input[id="start_date_lab"]').val(),
      end_date: $('input[id="end_date_lab"]').val(),
      card_no: $('input[id="card_no_lab"]').val(),
      birth_date: $('input[id="birth_date_lab"]').val(),
    }

    $.ajax({
      url: `/loas/search/lab`,
      headers: {"X-CSRF-TOKEN": csrf},
      data: {search: params},
      type: 'GET',
      success: function(response){
        var table = $('#tbl_lab').DataTable();
        table.destroy();
        $("#tbl_lab").remove();

        var table =
          "<table class='ui celled table big-table big-table' role='loa_table' id='tbl_lab' >"
          + "<thead>"
          + "<tr>"
          + "<td class='bold dim'>MEMBER INFORMATION</td>"
          + "<td class='bold dim'>PAYOR</td>"
          + "<td class='bold dim'>ISSUED DATE/TIME</td>"
          + "<td class='bold dim'>AMOUNT</td>"
          + "<td class='bold dim'>STATUS</td>"
          + "<td class='bold dim'>LOA NUMBER</td>"
          + "</tr>"
          + "</thead>"
          + "<tbody>"
        var data = ""

        if (response.loas.length == 0){
        }
        else {
          $.each(response.loas, function(i, lab){
            let status_class = "";
            let status = "";

            if(lab.status == "draft" || lab.status == "" || lab.status == null){
              status_class = "tag tag--blue";
              status = "draft";
            } else if(lab.status == "pending") {
              status_class = "tag tag--orange";
              status = "pending";
            } else if(lab.status == "approved") {
              status_class = "tag tag--green";
              status = "approved";
            } else if(lab.status == "cancelled") {
              status_class = "tag tag--black";
              status = "cancelled";
            } else if(lab.status == "disapproved") {
              status_class = "tag tag--red";
              status = "disapproved";
            }


            data = data
              + "<tr>"
              + "<td>"
              + "<a href='loas/" + lab.id + "/show'><div>Card No.: " + lab.card.number + "</div></a>"
              // + "<div>Member Name: " + lab.card.member.name + "</div>"
              + "<div>Age: " + lab.card.member.age + "</div>"
              // + "<div>Birth Date: " + lab.card.member.birth_date + "</div>"
              + "<div>Gender: " + lab.card.member.gender + "</div>"
              + "</td>"
              + "<td>" + "Maxicare" + "</td>"
              + "<td>" + lab.issue_date + "</td>"
              + "<td class='bold'>" + lab.total_amount + "</td>"
              + "<td>"
              + "<div class='" + status_class + "'>"
              + status + "</div>"
              + "</td>"
              + "<td>" + lab.loa_number + "</td>"
              + "</tr>"
          });

        }

        $('div[id="div_lab"]').html(table + data + "</tbody></table>");
        loadDataTable();

      }
    });

  });

});

onmount('div[id="loa_acu_search"]', function(){
  var table =
    $('#tbl_acu').dataTable({
	  	dom:
			"<'ui grid'"+
				"<'row'"+
					"<'eight wide column'l>"+
					"<'right aligned eight wide column'f>"+
				">"+
				"<'row dt-table'"+
					"<'sixteen wide column'tr>"+
				">"+
				"<'row'"+
					"<'seven wide column'i>"+
					"<'right aligned nine wide column'p>"+
				">"+
			">",
		renderer: 'semanticUI',
		pagingType: "full_numbers",
		language: {
			emptyTable:     "No Records Found!",
			zeroRecords:    "No Matching Records Found!",
			search:         "Search",
			paginate: {
				first: "<i class='angle single left icon'></i> First",
				previous: "<i class='angle double left icon'></i> Previous",
				next: "Next <i class='angle double right icon'></i>",
				last: "Last <i class='angle single right icon'></i>"
			}
    },
    searching: false,
    "lengthMenu": [[5, 10, 25, 50, -1], [5, 10, 25, 50, "All"]]
  });

  $('div[id="btn_search_acu"]').click(function () {

    let csrf = $('input[name="_csrf_token"]').val();
    let params = {
      loa_no: $('input[id="loa_no_acu"]').val(),
      start_date: $('input[id="start_date_acu"]').val(),
      end_date: $('input[id="end_date_acu"]').val(),
      status: $('input[id="acu_status"]').val(),
      payor: ""
    }

    $.ajax({
      url: `/loas/search/acu`,
      headers: {"X-CSRF-TOKEN": csrf},
      data: {search: params},
      type: 'GET',
      success: function(response){
        table.fnClearTable();
        $.each(response.loas, function(i, acu){

          let status_class = "";
          let status = "";
          let card_redirect = "";
          if (acu.status == null || acu.status == "" || acu.status.toLowerCase() == "draft"){
            card_redirect = `loas/${acu.payorlink_member_id}/package_info/${acu.verification_type}/${acu.id}`
          }else{
            card_redirect = `loas/${acu.id}/show`
          }
          if(acu.status == null) {
            status_class = "tag tag--blue";
            status = "draft";
          } else if(acu.status == "") {
            status_class = "tag tag--blue";
            status = "draft";
          } else if(acu.status.toLowerCase() == "draft") {
            status_class = "tag tag--blue";
            status = "draft";
          } else if(acu.status.toLowerCase() == "pending") {
            status_class = "tag tag--orange";
            status = "pending";
          } else if(acu.status.toLowerCase() == "approved") {
            status_class = "tag tag--green";
            status = "approved";
          } else if(acu.status.toLowerCase() == "cancelled") {
            status_class = "tag tag--black";
            status = "cancelled";
          } else if(acu.status.toLowerCase() == "disapproved") {
            status_class = "tag tag--red";
            status = "disapproved";
          } else if(acu.status.toLowerCase() == "forfeited") {
            status_class = "tag tag--red";
            status = "forfeited";
          } else if(acu.status.toLowerCase() == "forfeited") {
            status_class = "tag tag--orange";
            status = "forfeited";
          } else if(acu.status.toLowerCase() == "availed") {
            status_class = "tag tag--green";
            status = "availed";
          } else if(acu.status.toLowerCase() == "stale") {
            status_class = "tag tag--orange";
            status = "stale";
          }
          let input_check = ""
          if (acu.status != null && acu.status.toLowerCase() == "approved" && acu.is_cart == false && acu.is_batch == false){
            input_check = `<input style="width:20px; height:20px" type="checkbox" class="selection" value="${acu.id}" id="acu_loa_ids" data-value="${acu.id}">`
          }else{
            input_check = `<input style="width:20px; height:20px" type="checkbox" id="acu_loa_ids" class="selection" value="" data-value="${acu.id}">`
          }
          let payor = ""
          if (acu.payor != null){
            payor = acu.payor
          }
          let gender = "N/A"
          if (acu.gender != null){
            gender = acu.gender
          }
          let data1 = "<a href='" + card_redirect + "'><div>Card No: " + acu.card.member.card_number + "</div></a>"
          + "<div>Age: " + acu.card.member.age + "</div>"
          + "<div>Gender: " + gender + "</div>"
          let data3 = payor
          let data4 = acu.issue_date
          let data5 = acu.total_amount
          let data6 = "<div class='" + status_class + "'>"
          + status + "</div>"
          let data7 = acu.loa_number
          table.fnAddData([input_check,
                        data1,
                        data3,
                        data4,
                        data5,
                        data6,
                        data7]);

        })
        // var table = $('#tbl_acu').DataTable();
        // table.destroy();
        // $("#tbl_acu").remove();

        // var table =
        //   "<table class='ui celled table big-table big-table' role='loa_table' id='tbl_acu' >"
        //   + "<thead>"
        //   + "<tr>"
        //   + "<td class='bold dim'>MEMBER INFORMATION</td>"
        //   + "<td class='bold dim'>PAYOR</td>"
        //   + "<td class='bold dim'>ISSUED DATE/TIME</td>"
        //   + "<td class='bold dim'>AMOUNT</td>"
        //   + "<td class='bold dim'>STATUS</td>"
        //   + "<td class='bold dim'>LOA NUMBER</td>"
        //   // + "<td></td>"
        //   + "</tr>"
        //   + "</thead>"
        //   + "<tbody>"
        // var data = ""

        // if (response.loas.length == 0){
        // }
        // else {

        //   $.each(response.loas, function(i, acu){
        //     let status_class = "";
        //     let status = "";
        //     let card_redirect = "";

        //     // if (acu.otp == true){
        //     // status_class = "tag tag--violet";
        //     // status = "verified";
        //     // card_redirect = "loas/" + acu.id + "/show"
        //     if(acu.status == "draft" || acu.status == "" || acu.status == null){
        //       status_class = "tag tag--blue";
        //       status = "draft";
        //       card_redirect = "loas/" + acu.card.member.id + "/package_info/" + acu.verification_type + "/" + acu.id;
        //     } else if(acu.status == "pending") {
        //       status_class = "tag tag--orange";
        //       status = "pending";
        //       card_redirect = "loas/" + acu.id + "/show"
        //     } else if(acu.status == "approved") {
        //       status_class = "tag tag--green";
        //       status = "approved";
        //       card_redirect = "loas/" + acu.id + "/show"
        //     } else if(acu.status == "cancelled") {
        //       status_class = "tag tag--black";
        //       status = "cancelled";
        //       card_redirect = "loas/" + acu.id + "/show"
        //     } else if(acu.status == "disapproved") {
        //       status_class = "tag tag--red";
        //       status = "disapproved";
        //       card_redirect = "loas/" + acu.id + "/show"
        //     }

        //     data = data
        //       + "<tr>"
        //       + "<td>"
        //       + "<a href='" + card_redirect + "'><div>Card No.: " + acu.card.number + "</div></a>"
        //       // + "<div>Member Name: " + acu.card.member.name + "</div>"
        //       + "<div>Age: " + acu.card.member.age + "</div>"
        //       // + "<div>Birth Date: " + acu.card.member.birth_date + "</div>"
        //       + "<div>Gender: " + acu.card.member.gender + "</div>"
        //       + "</td>"
        //       + "<td>" + "Maxicare" + "</td>"
        //       + "<td>" + acu.issue_date + "</td>"
        //       + "<td class='bold'>" + acu.total_amount + "</td>"
        //       + "<td>"
        //       + "<div class='" + status_class + "'>"
        //       + status + "</div>"
        //       + "</td>"
        //       + "<td>" + acu.loa_number + "</td>"
        //       // + "<td><a href=''><span class='mobile-only mr-1'> Download </span><img src='images/table_row_download.png' alt=''></a></td>"
        //      + "</tr>"
        //   });

        // }

        // $('div[id="div_acu"]').html(table + data + "</tbody></table>");
        // loadDataTable();
      }
    });

  });

});

onmount('div[id="loa_peme_search"]', function(){
  var table =
    $('#tbl_peme').dataTable({
	  	dom:
			"<'ui grid'"+
				"<'row'"+
					"<'eight wide column'l>"+
					"<'right aligned eight wide column'f>"+
				">"+
				"<'row dt-table'"+
					"<'sixteen wide column'tr>"+
				">"+
				"<'row'"+
					"<'seven wide column'i>"+
					"<'right aligned nine wide column'p>"+
				">"+
			">",
		renderer: 'semanticUI',
		pagingType: "full_numbers",
		language: {
			emptyTable:     "No Records Found!",
			zeroRecords:    "No Matching Records Found!",
			search:         "Search",
			paginate: {
				first: "<i class='angle single left icon'></i> First",
				previous: "<i class='angle double left icon'></i> Previous",
				next: "Next <i class='angle double right icon'></i>",
				last: "Last <i class='angle single right icon'></i>"
			}
    },
    searching: false,
    "lengthMenu": [[5, 10, 25, 50, -1], [5, 10, 25, 50, "All"]],
    'columnDefs':[
      {
        'targets': 1,
        'createdCell': function (td, cellData, rowData, row, col) {
          $(td).attr('class', 'bold dim');
        }
      },
      {
        'targets': 2,
        'createdCell': function (td, cellData, rowData, row, col) {
          $(td).attr('class', 'bold dim');
        }
      },
      {
        'targets': 3,
        'createdCell': function (td, cellData, rowData, row, col) {
          $(td).attr('class', 'bold dim');
        }
      },
      {
        'targets': 4,
        'createdCell': function (td, cellData, rowData, row, col) {
          $(td).attr('class', 'bold dim');
        }
      },
      {
        'targets': 5,
        'createdCell': function (td, cellData, rowData, row, col) {
          $(td).attr('class', 'bold dim');
        }
      },
      {
        'targets': 6,
        'createdCell': function (td, cellData, rowData, row, col) {
          $(td).attr('class', 'bold dim');
        }
      },
      {
        'targets': 7,
        'createdCell': function (td, cellData, rowData, row, col) {
          $(td).attr('class', 'bold dim');
        }
      }

    ]
  });

  $('div[id="btn_search_peme"]').click(function () {

    let csrf = $('input[name="_csrf_token"]').val();
    let params = {
      loa_no: $('input[id="loa_no_peme"]').val(),
      start_date: $('input[id="start_date_peme"]').val(),
      end_date: $('input[id="end_date_peme"]').val(),
      card_no: $('input[id="evoucher_no_peme"]').val(),
      birth_date: $('input[id="birth_date_peme"]').val(),
    }
    $.ajax({
      url: `/loas/search/peme`,
      headers: {"X-CSRF-TOKEN": csrf},
      data: {search: params},
      type: 'GET',
      success: function(response){
        table.fnClearTable();
        $.each(response.loas, function(i, peme){
          let status_class = "";
          let status = "";
          let card_redirect = "";
          card_redirect = "loas/" + peme.id + "/show_peme"
          if(peme.status.toLowerCase() == "pending") {
            status_class = "tag tag--orange";
            status = "pending";
          } else if(peme.status.toLowerCase() == "approved") {
            status_class = "tag tag--green";
            status = "approved";
          } else if(peme.status.toLowerCase() == "cancelled") {
            status_class = "tag tag--black";
            status = "cancelled";
          } else if(peme.status.toLowerCase() == "disapproved") {
            status_class = "tag tag--red";
            status = "disapproved";
           } else if(peme.status.toLowerCase() == "availed") {
            status_class = "tag tag--green";
            status = "availed";
           }

          let payor = "";
          if (peme.payor != ""){
            payor = peme.payor.name
          }
          else {
            payor = "Maxicare"
          }
          let input_check = ""
          if (peme.status.toLowerCase() == "approved" && peme.is_cart == false && peme.is_batch == false){
            input_check = `<input style="width:20px; height:20px" type="checkbox" class="selection" value="${peme.id}" id="peme_loa_ids" data-value="${peme.id}">`
          }else{
            input_check = `<input style="width:20px; height:20px" type="checkbox" id="peme_loa_ids" class="selection" value="" data-value="${peme.id}" disabled >`
          }
          let data1 = "<a href='" + card_redirect + "'><div>Member ID: " + peme.member.id + "</div></a>"
          + "<div>Age: " + peme.member.age + "</div>"
          + "<div>Gender: " + peme.member.gender + "</div>"
          let data2 = peme.member.evoucher_number
          let data3 = payor
          let data4 = peme.issue_date
          let data5 = peme.total_amount
          let data6 = "<div class='" + status_class + "'>"
          + status + "</div>"
          let data7 = peme.loa_number
          table.fnAddData([input_check,
                        data1,
                        data2,
                        data3,
                        data4,
                        data5,
                        data6,
                        data7]);
        })
        // table.destroy();
        // $("#tbl_peme").remove();

        // var table =
        //   "<table class='ui celled table big-table big-table' style='width: 100%' role='loa_table' id='tbl_peme' >"
        //   + "<thead>"
        //   + "<tr>"
        //   + "<td><input type='checkbox' style='width:20px; height:20px; margin-left:13px' id='checkAllpeme'></td>"
        //   + "<td class='bold dim'>MEMBER INFORMATION</td>"
        //   + "<td class='bold dim'>E-VOUCHER NO</td>"
        //   + "<td class='bold dim'>PAYOR</td>"
        //   + "<td class='bold dim'>ISSUED DATE/TIME</td>"
        //   + "<td class='bold dim'>AMOUNT</td>"
        //   + "<td class='bold dim'>STATUS</td>"
        //   + "<td class='bold dim'>LOA NUMBER</td>"
        //   // + "<td></td>"
        //   + "</tr>"
        //   + "</thead>"
        //   + "<tbody>"
        // var data = ""

        // if (response.loas.length == 0){
        // }
        // else {

        //   $.each(response.loas, function(i, peme){
        //     let status_class = "";
        //     let status = "";
        //     let card_redirect = "";

        //     // if (peme.otp == true){
        //     // status_class = "tag tag--violet";
        //     // status = "verified";
        //     // card_redirect = "loas/" + peme.id + "/show"
        //     card_redirect = "loas/" + peme.id + "/show_peme"
        //     if(peme.status == "pending") {
        //       status_class = "tag tag--orange";
        //       status = "pending";
        //     } else if(peme.status == "approved") {
        //       status_class = "tag tag--green";
        //       status = "approved";
        //     } else if(peme.status == "cancelled") {
        //       status_class = "tag tag--black";
        //       status = "cancelled";
        //     } else if(peme.status == "disapproved") {
        //       status_class = "tag tag--red";
        //       status = "disapproved";
        //     }
        //     let input_check = ""
        //     if (peme.status == "Approved" && peme.is_cart == false && peme.is_batch == false){
        //     input_check = `<input style="width:20px; height:20px" type="checkbox" class="selection" value="${peme.id}" id="peme_loa_ids" data-value="${peme.id}">`
        //     }else{
        //      input_check = `<input style="width:20px; height:20px" type="checkbox" id="peme_loa_ids" class="selection" value="" data-value="${peme.id}" disabled >`
        //     }
        //     data = data
        //       + "<tr>"
        //       + "<td>"
        //       + input_check
        //       + "</td>"
        //       + "<td>"
        //       + "<a href='" + card_redirect + "'><div>Member ID: " + peme.member.id + "</div></a>"
        //       // + "<div>Member Name: " + peme.card.member.name + "</div>"
        //       + "<div>Age: " + peme.member.age + "</div>"
        //       // + "<div>Birth Date: " + peme.card.member.birth_date + "</div>"
        //       + "<div>Gender: " + peme.member.gender + "</div>"
        //       + "</td>"
        //       + "<td>" + peme.member.evoucher_number + "</td>"
        //       + "<td>" + "Maxicare" + "</td>"
        //       + "<td>" + peme.issue_date + "</td>"
        //       + "<td class='bold'>" + peme.total_amount + "</td>"
        //       + "<td>"
        //       + "<div class='" + status_class + "'>"
        //       + status + "</div>"
        //       + "</td>"
        //       + "<td>" + peme.loa_number + "</td>"
        //       // + "<td><a href=''><span class='mobile-only mr-1'> Download </span><img src='images/table_row_download.png' alt=''></a></td>"
        //      + "</tr>"
        //   });

        // }

        // $('div[id="div_peme"]').html(table + data + "</tbody></table>");
        // loadDataTable();
      }
    });

  });

});


onmount('table[id="cart_table"]', function () {
 $('table[id="cart_table"]').DataTable({
	  	dom:
			"<'ui grid'"+
				"<'row'"+
					"<'eight wide column'l>"+
					"<'right aligned eight wide column'f>"+
				">"+
				"<'row dt-table'"+
					"<'sixteen wide column'tr>"+
				">"+
				"<'row'"+
					"<'seven wide column'i>"+
					"<'right aligned nine wide column'p>"+
				">"+
			">",
		renderer: 'semanticUI',
		pagingType: "full_numbers",
    bLengthChange: false,
    bFilter: false,
		language: {
			emptyTable:     "No Records Found.",
			zeroRecords:    "No Records Found.",
			search:         "Search",
			paginate: {
				first: "<i class='angle single left icon'></i> First",
				previous: "<i class='angle double left icon'></i> Previous",
				next: "Next <i class='angle double right icon'></i>",
				last: "Last <i class='angle single right icon'></i>"
			}
    },
  })
});
