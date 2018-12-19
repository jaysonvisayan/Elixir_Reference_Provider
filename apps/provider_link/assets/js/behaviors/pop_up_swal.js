onmount('input[id="pop-up-loa-show-swal"]', function(){
  swal({
    title: 'LOA successfully created',
    text: `Please proceed with ACU availment`,
    type: 'info',
    confirmButtonText: '<i class="check icon"></i> Okay',
    confirmButtonClass: 'ui blue button',
    buttonsStyling: false,
    reverseButtons: true,
    allowOutsideClick: false
  })
})
