onmount('div[role="loa_date_picker"]', function(){
  var currentLocaleData = moment.localeData();
  currentLocaleData = moment(currentLocaleData).format("YYYY-MM-DD");
  let end_date = moment(currentLocaleData, "YYYY-MM-DD").add(2, 'days');
  end_date = moment(end_date).format("YYYY-MM-DD");

  $('div[name="consultation_date"]').calendar({
    type: 'date',
    minDate: new Date(currentLocaleData),
    maxDate: new Date(end_date),
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

});

onmount('div[role="date_picker"]', function(){

  $('div[name="range_start_date"]').calendar({
    type: 'date',
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
            return month + '/' + day + '/' + year;
        }
    }
  });

  $('div[name="range_end_date"]').calendar({
    type: 'date',
    startCalendar: $('div[name="range_start_date"]'),
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
            return month + '/' + day + '/' + year;
        }
    }
  });

  $('div[name="start_date"]').calendar({
    type: 'date',
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
            return month + '/' + day + '/' + year;
        }
    }
  });

});
