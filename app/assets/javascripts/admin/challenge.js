$(function() {
  var to = new Date();
  var from = new Date();

  var $elem = $('#start-end-date')
  $elem.DatePicker({
    inline: true,
    date: [from, to],
    calendars: 3,
    mode: 'range',
    onChange: function(dates,el) {
      // update the range display
      $('#start-end-date span#display').text(
        dates[0].getDate()+' '+dates[0].getMonthName(true)+', '+
        dates[0].getFullYear()+' - '+
        dates[1].getDate()+' '+dates[1].getMonthName(true)+', '+
        dates[1].getFullYear());
      $('#date-range-hidden-start').val($elem.DatePickerGetDate()[0][0])
      $('#date-range-hidden-end').val($elem.DatePickerGetDate()[0][1])
    }
  });
  $('#date-range-hidden-start').val($elem.DatePickerGetDate()[0][0])
  $('#date-range-hidden-end').val($elem.DatePickerGetDate()[0][1])


  // initialize the special date dropdown field
  $('#start-end-date span#display').text(from.getDate()+' '+from.getMonthName(true)+', '+from.getFullYear()+' - '+
                                      to.getDate()+' '+to.getMonthName(true)+', '+to.getFullYear());

})

$(function() {
  var from = new Date();
  var $elem = $('#winner-announced-date')
  $elem.DatePicker({
    mode: 'single',
    calendars: 3,
    inline: true,
    date: new Date(),
    onChange: function(date,el) {
      // update the range display
      $('#winner-announced-date span#display').text(
        date.getDate()+' '+date.getMonthName(true)+', '+
        date.getFullYear())
      $('#winner-announced-hidden').val($elem.DatePickerGetDate()[0][0])
    }
  })
  $('#winner-announced-hidden').val($elem.DatePickerGetDate()[0][0])

  // initialize the special date dropdown field
  $('#winner-announced-date span#display').text(from.getDate()+' '+from.getMonthName(true)+', '+from.getFullYear());

})
