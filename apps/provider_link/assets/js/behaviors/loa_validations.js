onmount('div[role="loa-validation"]', function(){
  let currentLocaleData = moment.localeData();
  currentLocaleData = moment(currentLocaleData).format("YYYY-MM-DD");
  let admission_date_selector = $('input[name="loa[admission_date]"]');

  if (admission_date_selector.val() == "") {
    admission_date_selector.val(currentLocaleData)
  }

  $('div[id="admission-date"]').calendar({
    type: 'date',
    minDate: new Date(currentLocaleData),
    maxDate: new Date(currentLocaleData),
    formatter: {
        date: function (date, settings) {
            if (!date) return '';
            var day = date.getDate() + '';
            if (day.length < 2) {
                day = '0' + day;
            }
            var month = (date.getMonth() + 1) + '';
            if (month.length < 2) {
                month = '0' + month;
            }
            var year = date.getFullYear();
            return year + '-' + month + '-' + day;
        }
    }
  });

  $('div[id="discharge-date"]').calendar({
    type: 'date',
    minDate: new Date(currentLocaleData),
    formatter: {
        date: function (date, settings) {
            if (!date) return '';
            var day = date.getDate() + '';
            if (day.length < 2) {
                day = '0' + day;
            }
            var month = (date.getMonth() + 1) + '';
            if (month.length < 2) {
                month = '0' + month;
            }
            var year = date.getFullYear();
            return year + '-' + month + '-' + day;
        }
    }
  });

  $.fn.form.settings.rules.GreaterThanAdmissionDate= function(param) {
    let admission_date = $('input[name="loa[admission_date]"]').val()
    let discharge_date= $('input[name="loa[discharge_date]"]').val()

    if(admission_date <= discharge_date){
      return true
    }else{
      return false
    }
  }

  $('#loa').form({
    inline: true,
    on: 'blur',
    fields: {
      'loa[admission_date]': {
        identifier: 'loa[admission_date]',
        rules: [{
          type  : 'empty',
          prompt: 'Please enter Admission Date'
        },]
      },
      'loa[discharge_date]': {
        identifier: 'loa[discharge_date]',
        rules: [{
          type  : 'empty',
          prompt: 'Please enter Discharge Date'
        },
        {
          type  : 'GreaterThanAdmissionDate[param]',
          prompt: 'Discharge Date must be greater than or equal to the Admission Date'
        }
        ]
      }
    }
  })
})
