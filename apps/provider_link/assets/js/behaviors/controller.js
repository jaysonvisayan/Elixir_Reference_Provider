$('.ui.dropdown').dropdown();
$('.ui.radio.checkbox').checkbox();

// Open and Close Triggered Panel which click on the Button
var trigger = $('.right-side-out__trigger-button'),
    triggered = $('.right-side-out');
trigger.click(function() {
    if (!triggered.hasClass('slide-in')) {
        triggered.addClass('slide-in');
        $(this).find('span').html('Cancel');
    } else {
        triggered.removeClass('slide-in');
        $(this).find('span').html('New');
    }
})

// Close Triggered When clicked outside of the div
$(document).mouseup(function(e) {
    // If the target of the click isn't the container nor a descendant of the container
    if (!triggered.is(e.target) && triggered.has(e.target).length === 0) {
        triggered.removeClass('slide-in');
        $(trigger).find('span').html('New');
    }
});

//Open modal
// $('.ui.tiny.modal.modal-main')
//   .modal('attach events', '.modal-open-main', 'show')
// ;
// $('.ui.tiny.modal.modal-success')
//   .modal('attach events', '.modal-open-success', 'show')
// ;
// $('.ui.tiny.modal.modal-fail')
//   .modal('attach events', '.modal-open-fail', 'show')
// ;
// $('.ui.tiny.modal.modal-member-info')
//   .modal('attach events', '.modal-open-member-info', 'show')
// ;

$('.menu .item')
    .tab();

$('#rangeStartDate').calendar({
    type: 'date',
    endCalendar: $('#rangeEndDate')
});

$('#rangeEndDate').calendar({
    type: 'date',
    startCalendar: $('#rangeStartDate')
});

$('#birthDate').calendar({
    type: 'date'
});

$('#procedureDate').calendar({
    type: 'date'
});

//Member card - only 4 numbers per box
$(document).ready(function() {
    $(".member-card-number").keyup(function() {
        if ($(this).val().length >= 4) {
            var input_flds = $(this).closest('form').find(':input');
            input_flds.eq(input_flds.index(this) + 1).focus();
        }
    });
});