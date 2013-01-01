$(function() {
  var to = new Date();
  var from = new Date();

  var $elem = $('#start-end-date')
  $elem.DatePicker({
    inline: true,
    date: [from, to],
    calendars: 2,
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
    calendars: 2,
    inline: true,
    date: new Date(),
    onChange: function(date,el) {
      // update the range display
      $('#winner-announced-date span#display').text(
        date.getDate()+' '+date.getMonthName(true)+', '+
        date.getFullYear())
      $('#winner-announced-hidden').val($elem.DatePickerGetDate()[0])
    }
  })
  $('#winner-announced-hidden').val($elem.DatePickerGetDate()[0])

  // initialize the special date dropdown field
  $('#winner-announced-date span#display').text(from.getDate()+' '+from.getMonthName(true)+', '+from.getFullYear());

})

$(function() {
  var member_search_settings = {
    placeholder: "Search for a member",
    minimumInputLength: 1,
    multiple: true,
    id: "name",
    ajax: { // instead of writing the function to execute the request we use Select2's convenient helper
        url: "/members/search",
        dataType: 'jsonp',
        data: function (term, page) {
          return {
            keyword: term, // search term
          };
        },
        results: function (data, page) { // parse the results into the format expected by Select2.
          // since we are using custom formatting functions we do not need to alter remote JSON data
          return {results: data};
        }
    },
    formatResult: function(member) {
      return member.name
    },
    formatSelection: function(member) {
      return member.name
    },
    containerCssClass: "span12" // apply css that makes the dropdown taller
  }
  $('#admin_challenge_reviewers').select2(member_search_settings)
  $('#admin_challenge_categories').select2({
    containerCssClass: "span12"
  })
  $('#admin_challenge_commentNotifiers').select2(member_search_settings)
})