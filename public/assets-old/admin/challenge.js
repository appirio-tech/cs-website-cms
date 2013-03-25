$(function() {
  // Add new prize sets
  $('.add-new-prize-set').live('click', function(e) {
    $('#prize-set').append('\
<div class="well"><div class="control-group"> \
  <label class="control-label">Place</label> \
  <div class="controls"> \
    <input type="number" name="admin_challenge[prizes][][place]"></input> \
  </div> \
</div> \
<div class="control-group"> \
  <label class="control-label">Prize</label> \
  <div class="controls"> \
    <input type="number" name="admin_challenge[prizes][][prize]" class="prize-prize"></input> \
  </div> \
</div> \
<div class="control-group"> \
  <label class="control-label">Points</label> \
  <div class="controls"> \
    <input type="number" name="admin_challenge[prizes][][points]" class="prize-points"></input> \
  </div> \
</div> \
<div class="control-group"> \
  <label class="control-label">Value</label> \
  <div class="controls"> \
    <input type="number" name="admin_challenge[prizes][][value]" class="prize-value"></input> \
  </div> \
</div> \
<a class="btn btn-danger delete-prize-set">Delete This Prize Set</a> \
</div>')
    e.preventDefault()
  })

  // Delete prize sets
  $('.delete-prize-set').live('click', function(e) {
    $(this).parent().fadeOut().empty()
    e.preventDefault()
  })

  // Add/Remove assets
  $('a.delete-asset').on('click', function(e) {
    filename = $(this).data('filename')

    // remove the asset from the hidden field
    $('#admin_challenge_assets').val(function(i, v) {
      var arr = v.split(',')
      for (var i in arr) {
        if (arr[i] == filename) {
          arr.splice(i, 1)
          break
        }
      }
      return arr.join(',')
    })

    $(this).parent().fadeOut()
    e.preventDefault()
  })

  // onBlur thingie for prizes
  $('input.prize-prize').live('blur', function(e) {
    value = this.value.replace(/[$,]/g,"")
    if (isNaN(value) == false) {
      $great_grand_parent = $(this).parent().parent().parent()
      $great_grand_parent.find('input.prize-points').val(value)
      $great_grand_parent.find('input.prize-value').val(value)
    }

    // value
  })

})
;
