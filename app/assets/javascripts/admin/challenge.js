$(function() {
  $('.add-new-prize-set').on('click', function() {
    $('#prize-set').append('\
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
