onmount('div[role="member-mobile-validate"]', function(){
  const all_members_mobile_no = []
  const csrf = $('input[name="_csrf_token"]').val()
  const member_type = $('input[name="member[member_type]"]').val()
  const member_id = $('input[name="member[member_id]"]').val()
  const current_mobile_no = $('input[name="member[current_mobile]"]').val()

  if (member_type.toLowerCase() == "dependent") {
    let checkMobileNo = () => {
      $.ajax({
        url:`/members/${member_id}/get_all_mobile_no`,
          headers: {"x-csrf-token": csrf},
          type: 'get',
          datatype: 'json',
          success: function(response){
            let obj = JSON.parse(response)
            all_members_mobile_no.push(obj)
          }, error: function(){
            alert('Error when getting data from payorlink')
          }
      });
    }
  checkMobileNo()
  } else {
    let checkMobileNo = () => {
      $.ajax({
        url:`/members/principal/get_all_mobile_no`,
          headers: {"x-csrf-token": csrf},
          type: 'get',
          datatype: 'json',
          success: function(response){
            let obj = JSON.parse(response)
            all_members_mobile_no.push(obj)
          }, error: function(){
            alert('Error when getting data from payorlink')
          }
      });
    }
  checkMobileNo()
  }

  //console.log(all_members_mobile_no)

  $.fn.form.settings.rules.checkMobile= function(param) {
    if(all_members_mobile_no[0].includes(param)){
      return false
    } else{
      return true
    }
  }

  $.fn.form.settings.rules.sameMobile= function(param) {
    param = param.replace(/-/g, "")
    if(param == current_mobile_no){
      return false
    } else{
      return true
    }
  }

  $.fn.form.settings.rules.checkLength= function(param) {
    if(param.length == 14){
      return true
    } else{
      return false
    }
  }

  $('#update_mobile_no_form').form({
    inline: true,
    on: 'blur',
    fields: {
      'member[mobile]': {
        identifier: 'member[mobile]',
        rules: [{
          type  : 'empty',
          prompt: 'Please enter Mobile No'
        },
        {
          type : 'checkLength[param]',
          prompt: 'Mobile No should be 11 digits'
        },
        {
          type : 'sameMobile[param]',
          prompt: 'Mobile Number must not be the same with the current mobile number.'
        },
        {
          type : 'checkMobile[param]',
          prompt: 'Mobile number is already taken'
        }
        ]
      }
    }
  })

  $('#create_mobile_no_form').form({
    inline: true,
    on: 'blur',
    fields: {
      'member[mobile]': {
        identifier: 'member[mobile]',
        rules: [{
          type  : 'empty',
          prompt: 'Please enter Mobile No'
        },
        {
          type : 'checkLength[param]',
          prompt: 'Mobile No should be 11 digits'
        },
        {
          type : 'checkMobile[param]',
          prompt: 'Mobile number is already taken'
        }]
      }
    }
  })

})
