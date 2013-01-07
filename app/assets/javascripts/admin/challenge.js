$(function() {
  var to = new Date();
  to.setDate(to.getDate() + 14)
  var $elem = $('#winner-announced-date')
  $elem.DatePicker({
    mode: 'single',
    calendars: 3,
    inline: true,
    date: to,
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
  $('#winner-announced-date span#display').text(to.getDate()+' '+to.getMonthName(true)+', '+to.getFullYear());

})


$(function() {
  $('.add-new-prize-set').on('click', function() {
    $('#prizes').append('\
<div class="controls"> \
  <hr /> \
</div> \
<div class="control-group"> \
  <label class="control-label">Place</label> \
  <div class="controls"> \
    <input type="number" name="admin_challenge[prizes][][place]"></input> \
  </div> \
</div> \
<div class="control-group"> \
  <label class="control-label">Prize</label> \
  <div class="controls"> \
    <input type="number" name="admin_challenge[prizes][][prize]"></input> \
  </div> \
</div> \
<div class="control-group"> \
  <label class="control-label">Points</label> \
  <div class="controls"> \
    <input type="number" name="admin_challenge[prizes][][points]"></input> \
  </div> \
</div> \
<div class="control-group"> \
  <label class="control-label">Value</label> \
  <div class="controls"> \
    <input type="number" name="admin_challenge[prizes][][value]"></input> \
  </div> \
</div>')
  })
})
