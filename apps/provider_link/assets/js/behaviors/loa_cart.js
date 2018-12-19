onmount('#add_to_cart_acu', function(){
  const csrf = $('input[name="_csrf_token"]').val();
  let acu_ids = []
  let files = []
  let amounts = []


  $('.valid_timezone').each(function(){
    let val = $(this).text()
    $(this).text(moment(val).format("MMMM DD, YYYY hh:mm A"));
  })

Array.prototype.delayedForEach = function(callback, timeout, thisArg, done){
    var i = 0,
        l = this.length,
        self = this;

    var caller = function() {
        callback.call(thisArg || self, self[i], i, self);
        if(++i < l) {
            setTimeout(caller, timeout);
        } else if(done) {
            setTimeout(done, timeout);
        }
    };

    caller();
};


  $('#tbl_acu').find('tbody').find('tr').find('input[type="checkbox"]').on('change', function(){
      let values = 0
      $('#tbl_acu').find('input[type="checkbox"]').each(function(index, value) {
        let state = $(this).is(':checked')
        if(state) {
          let total_amount = parseFloat( $(this).attr('totalamount') )
          console.log($(this).attr('totalamount'))
          if (isNaN(total_amount) == false) {
            values += total_amount
          }
        }
      })
      $('#cartTotal').html(`₱ ${values}`)


      // let total_amount = $(this).attr('totalamount')
      // let value = $(this).val()
      // let check = $(this).attr("checked")
      // let sum = 0;

      // // let created_date = $(this).closest('td').closest('tr').find('.valid_timezone').text()
      // // value = `{"id": "${value}"}`
      // if($(this).is(":checked")){
      //   $("#add_to_cart_acu").removeClass("disabled")
      //   acu_ids.push(value)
      //   amounts.push(total_amount)
      //   let n = amounts.length
      //   while(n--)
      //     sum += parseFloat(amounts[n]) || 0;
      //   console.log(sum)
      //   $('#cartTotal').html(`₱ ${sum}`)
      // } else {
      //   let index = acu_ids.indexOf(value);
      //   if (index > 0) {
      //      acu_ids.splice( index, 1)
      //   let n = amounts.length
      //   let diff = sum-- ;
      //   while(n--)
      //     diff -= parseFloat(amounts[n]) || 0;
      //   console.log(diff)
      //   $('#cartTotal').html(`₱ ${diff}`)
      //   }
      //   else{
      //   $("#add_to_cart_acu").addClass("disabled")
      //   }
      // }
    })



  $('#add_to_cart_acu').on('click', function(){
    console.log(acu_ids)
    // console.log(JSON.parse(acu_ids))
    // console.log($('input[name="loa[loa_ids]"]').val())
    // let input_id = $('#loa_ids_acu').val(acu_ids)
    // console.log(input_id)
    if (acu_ids.length){
      let input_id = $('#loa_ids_acu').val(acu_ids)
    }
    else{
      let input_id = $('#loa_ids_acu').val([])
    }
  })

 // FOR CHECK ALL
  $('#checkAllacu').on('change', function(){
    var table = $('#tbl_acu').DataTable()
    var rows = table.rows({ 'search': 'applied' }).nodes();

    if ($(this).is(':checked')) {
      $("#add_to_cart_acu").removeClass("disabled")
      acu_ids = []
      $('input[type="checkbox"]', rows).each(function() {
      // let created_date = $(this).closest('td').closest('tr').find('.valid_timezone').text()
      var value = $(this).val()
      // value = `{"id": "${value}"}`
        if (this.checked) {
          acu_ids.push(value)
        } else {
          var index = acu_ids.indexOf(value);

          if (index >= 0) {
            acu_ids.splice(index, 1)
          }
          acu_ids.push(value)
        }
        if($(this).prop('disabled')){
          $(this).prop('checked', false)
        }else{
          $(this).prop('checked', true)
        }
      })
    }
 else {
      acu_ids.length = 0
      $('input[id="acu_loa_ids"]').each(function() {
        $(this).prop('checked', false)
      })
      $("#add_to_cart_acu").addClass("disabled")
    }

      let values = 0
      $('#tbl_acu').find('input[type="checkbox"]').each(function(index, value) {
        let state = $(this).is(':checked')
        if(state) {
          let total_amount = parseFloat( $(this).attr('totalamount') )
          console.log($(this).attr('totalamount'))
          if (isNaN(total_amount) == false) {
            values += total_amount
          }
        }
      })
      console.log(`${values} haha`)
      $('#cartTotal').html(`₱ ${values}`)
  })

})

onmount('.remove_to_cart', function(){
  $('.remove_to_cart').on('click', function(){
  let value = $(this).attr('remove_id')
  $(this).closest('#loa_cart').remove()
  $(`input[data-value="${value}"]`).removeAttr('disabled')
  $.ajax({
    url:`/loas/remove_to_cart/${value}`,
    type: 'GET',
    success: function(response){
      $('#count').html(response.count)
    }
  })
  if($('#count').html() == 0 || $('#count').html() == 1){
    $('#add_to_batch').remove()
    $('#search_append').remove()
  }
  })
})

onmount('#add_to_batch', function(){

  $("#add_to_batch").on('click', function(){
    $('#modal_add_to_batch').modal({
      closable: false,
      autofocus: false,
      observeChanges: true,
    }).modal('show')
  })
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
  $('#existing').click(function() {
      $('div[id="message"]').remove()
      type.val('existing')
      $('.card').removeAttr("style")
      $(this).css("background-color", "#00DDFB");
  })
  $('#proceed_button_add_batch').click(function() {
      if (type.val() == "hb") {
          window.location.href = `/batch/loa/new?type=hospital_bill`
      } else if (type.val() == "pf") {
          window.location.href = `/batch/loa/new?type=practitioner`
      } else if (type.val() == "existing"){
          $('#modal_list_batch').modal({
            closable: false,
            autofocus: false,
            observeChanges: true,
          }).modal('show')
      } else {
      $('div[id="message"]').remove()
      $('p#proceed').append('<div id="message" class="ui negative message"><ul class="list"><li>Please select atleast one type.</li> </ul> </div>')
      }
  })

  $('#cancel_add_existing').on('click', function(){
    $('#modal_add_to_batch').modal({
      closable: false,
      autofocus: false,
      observeChanges: true,
    }).modal('show')
  })
  $('form[name="add_to_batch"]')
    .form({
      on: 'blur',
      inline: true,
      fields: {
        'loa_batch[batch_no]': {
          rules: [{
            type: 'empty',
            prompt: 'Please enter batch no'
          }]
        }
      }
    })
})

onmount('#add_to_cart_peme', function(){
  const csrf = $('input[name="_csrf_token"]').val();
  let peme_ids = []
  let files = []


  $('.valid_timezone').each(function(){
    let val = $(this).text()
    $(this).text(moment(val).format("MMMM DD, YYYY hh:mm A"));
  })

Array.prototype.delayedForEach = function(callback, timeout, thisArg, done){
    var i = 0,
        l = this.length,
        self = this;

    var caller = function() {
        callback.call(thisArg || self, self[i], i, self);
        if(++i < l) {
            setTimeout(caller, timeout);
        } else if(done) {
            setTimeout(done, timeout);
        }
    };

    caller();
};


  $('#tbl_peme').find('tbody').find('tr').find('input[type="checkbox"]').on('change', function(){
      let value = $(this).val()
      let check = $(this).attr("checked")
      // let created_date = $(this).closest('td').closest('tr').find('.valid_timezone').text()
      // value = `{"id": "${value}"}`
      if($(this).is(":checked")){
        $("#add_to_cart_peme").removeClass("disabled")
        peme_ids.push(value)
      } else {
        let index = peme_ids.indexOf(value);
        if (index >= 0) {
           peme_ids.splice( index, 1)
        }
        else{
        $("#add_to_cart_peme").addClass("disabled")
        }
      }
    })

  $('#add_to_cart_peme').on('click', function(){
    // let input_id = $('#loa_ids_peme').val(peme_ids)
    if (peme_ids.length){
      let input_id = $('#loa_ids_peme').val(peme_ids)
    }
    else{
      let input_id = $('#loa_ids_peme').val([])
    }
  })

 // FOR CHECK ALL
  $('#checkAllpeme').on('change', function(){
    var table = $('#tbl_peme').DataTable()
    var rows = table.rows({ 'search': 'applied' }).nodes();

    if ($(this).is(':checked')) {
      $("#add_to_cart_peme").removeClass("disabled")
      let peme_ids = []
      $('input[type="checkbox"]', rows).each(function() {
      // let created_date = $(this).closest('td').closest('tr').find('.valid_timezone').text()
      var value = $(this).val()
      // value = `{"id": "${value}"}`
        if (this.checked) {
          peme_ids.push(value)
        } else {
          var index = peme_ids.indexOf(value);

          if (index >= 0) {
            peme_ids.splice(index, 1)
          }
          peme_ids.push(value)
        }
        if($(this).prop('disabled')){
          $(this).prop('checked', false)
        }else{
          $(this).prop('checked', true)
        }
      })
    }
 else {
      peme_ids.length = 0
      $('input[id="peme_loa_ids"]').each(function() {
        $(this).prop('checked', false)
      })
      $("#add_to_cart_peme").addClass("disabled")
    }
  })

})

onmount('div[id="add_to_cart"]', function() {
    $('#cart_search').on('keyup', function() {
        let value = $(this).val()

        if (value != "") {
            $('.original').hide()
            $.ajax({
                url: `/loas/${value}/search_loa`,
                type: 'GET',
                success: function(response) {
                    $(".new_row").remove()
                    if (response.loas[0] != undefined) {
                        for (let loa of response.loas) {
                            let new_row =
                                `<div class="item new_row" id="loa_cart" loa_id="${loa.id}"  style="width:300px;margin-left: 10px;margin-right: 10px" >\
                    <div class="ui grid">\
                      <div class="row">\
                        <div class="twelve wide column">\
                          <a href="loas/${loa.id}/show"> LOA No: ${loa.loa_number}</a><br />\
                            Amount: ${loa.total_amount}<br />\
                            Availment Date: ${loa.inserted_at}\
                        </div>\
                        <div class="four wide column" id="remove_to_cart" remove_id="<%= acu.id%>" style="cursor: pointer">\
                          <i class="remove icon large"></i>\
                        </div>\
                      </div>\
                    </div>\
                  </div>\
                  <div class="original divider"></div>`
                            $("#search_append").append(new_row)
                        }
                    } else {
                        let new_row =
                            `<div class="item new_row" style="width:300px;margin-left: 10px;margin-right: 10px; >\
                    <div class="ui grid">\
                      <div class="row">\
                        <div class="sixteen wide column">\
                          No Records Found.
                        </div>\
                      </div>\
                    </div>\
                  </div>\
                  <div class="original divider"></div>`
                        $("#search_append").append(new_row)
                    }
                }
            })
        } else {
            $(".new_row").remove()
            $('.original').show()
        }
    })

})

onmount('#add_to_cart_consult', function(){
  const csrf = $('input[name="_csrf_token"]').val();
  let consult_ids = []
  let files = []


  $('.valid_timezone').each(function(){
    let val = $(this).text()
    $(this).text(moment(val).format("MMMM DD, YYYY hh:mm A"));
  })

Array.prototype.delayedForEach = function(callback, timeout, thisArg, done){
    var i = 0,
        l = this.length,
        self = this;

    var caller = function() {
        callback.call(thisArg || self, self[i], i, self);
        if(++i < l) {
            setTimeout(caller, timeout);
        } else if(done) {
            setTimeout(done, timeout);
        }
    };

    caller();
};


  $('#tbl_consult').find('tbody').find('tr').find('input[type="checkbox"]').on('change', function(){
      let value = $(this).val()
      let check = $(this).attr("checked")
      // let created_date = $(this).closest('td').closest('tr').find('.valid_timezone').text()
      // value = `{"id": "${value}"}`
      if($(this).is(":checked")){
        $("#add_to_cart_consult").removeClass("disabled")
        consult_ids.push(value)
      } else {
        let index = consult_ids.indexOf(value);
        if (index >= 0) {
           consult_ids.splice( index, 1)
        }
        else{
        $("#add_to_cart_consult").addClass("disabled")
        }
      }
    })



  $('#add_to_cart_consult').on('click', function(){
    // console.log(acu_ids)
    // console.log(JSON.parse(acu_ids))
    // console.log($('input[name="loa[loa_ids]"]').val())
    if (consult_ids.length){
      let input_id = $('#loa_ids_consult').val(consult_ids)
    }
    else{
      let input_id = $('#loa_ids_consult').val([])
    }
  })

 // FOR CHECK ALL
  $('#checkAllconsult').on('change', function(){
    var table = $('#tbl_consult').DataTable()
    var rows = table.rows({ 'search': 'applied' }).nodes();

    if ($(this).is(':checked')) {
      $("#add_to_cart_consult").removeClass("disabled")
      consult_ids = []
      $('input[type="checkbox"]', rows).each(function() {
      // let created_date = $(this).closest('td').closest('tr').find('.valid_timezone').text()
      var value = $(this).val()
      // value = `{"id": "${value}"}`
        if (this.checked) {
          consult_ids.push(value)
        } else {
          var index = consult_ids.indexOf(value);

          if (index >= 0) {
            consult_ids.splice(index, 1)
          }
          consult_ids.push(value)
        }
        if($(this).prop('disabled')){
          $(this).prop('checked', false)
        }else{
          $(this).prop('checked', true)
        }
      })
    }
 else {
      consult_ids.length = 0
      $('input[id="consult_loa_ids"]').each(function() {
        $(this).prop('checked', false)
      })
      $("#add_to_cart_consult").addClass("disabled")
    }
  })

})

onmount('#add_to_lab_consult', function(){
  const csrf = $('input[name="_csrf_token"]').val();
  let lab_ids = []
  let files = []


  $('.valid_timezone').each(function(){
    let val = $(this).text()
    $(this).text(moment(val).format("MMMM DD, YYYY hh:mm A"));
  })

Array.prototype.delayedForEach = function(callback, timeout, thisArg, done){
    var i = 0,
        l = this.length,
        self = this;

    var caller = function() {
        callback.call(thisArg || self, self[i], i, self);
        if(++i < l) {
            setTimeout(caller, timeout);
        } else if(done) {
            setTimeout(done, timeout);
        }
    };

    caller();
};


  $('#tbl_lab').find('tbody').find('tr').find('input[type="checkbox"]').on('change', function(){
      let value = $(this).val()
      let check = $(this).attr("checked")
      // let created_date = $(this).closest('td').closest('tr').find('.valid_timezone').text()
      // value = `{"id": "${value}"}`
      if($(this).is(":checked")){
        $("#add_to_cart_lab").removeClass("disabled")
        lab_ids.push(value)
      } else {
        let index = lab_ids.indexOf(value);
        if (index >= 0) {
           lab_ids.splice( index, 1)
        }
        else{
        $("#add_to_cart_lab").addClass("disabled")
        }
      }
    })



  $('#add_to_cart_lab').on('click', function(){
    // console.log(acu_ids)
    // console.log(JSON.parse(acu_ids))
    // console.log($('input[name="loa[loa_ids]"]').val())
    if (lab_ids.length){
      let input_id = $('#loa_ids_lab').val(lab_ids)
    }
    else{
      let input_id = $('#loa_ids_lab').val([])
    }
  })

 // FOR CHECK ALL
  $('#checkAlllab').on('change', function(){
    var table = $('#tbl_lab').DataTable()
    var rows = table.rows({ 'search': 'applied' }).nodes();

    if ($(this).is(':checked')) {
      $("#add_to_cart_lab").removeClass("disabled")
      lab_ids = []
      $('input[type="checkbox"]', rows).each(function() {
      // let created_date = $(this).closest('td').closest('tr').find('.valid_timezone').text()
      var value = $(this).val()
      // value = `{"id": "${value}"}`
        if (this.checked) {
          lab_ids.push(value)
        } else {
          var index = lab_ids.indexOf(value);

          if (index >= 0) {
            lab_ids.splice(index, 1)
          }
          lab_ids.push(value)
        }
        if($(this).prop('disabled')){
          $(this).prop('checked', false)
        }else{
          $(this).prop('checked', true)
        }
      })
    }
 else {
      lab_ids.length = 0
      $('input[id="lab_loa_ids"]').each(function() {
        $(this).prop('checked', false)
      })
      $("#add_to_cart_lab").addClass("disabled")
    }
  })

})

onmount('div[id="modal_list_batch"]', function(){
  let table = $('#batch_table').DataTable();
  let row = $('#batch_row')

  $('div[id="modal_list_batch').on('mouseenter', function() {

    $('tr[role="row"]').on( 'click', function () {
        if ($(this).hasClass('active') ) {
            $('input[name="loa_batch[batch_no]"]').val()
            $(this).removeClass('active');
            $('input[name="loa_batch[batch_no]"]').val($(this).attr('batch_number'))
        }
        else {
            table.$('tr.active').removeClass('active');
            $('input[name="loa_batch[batch_no]"]').val()
            $(this).addClass('active');
            $('input[name="loa_batch[batch_no]"]').val($(this).attr('batch_number'))
        }
    } );
  })

})
