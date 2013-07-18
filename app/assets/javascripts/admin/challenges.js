// listen when a sysadmin changes the sponsor to show challenges for
function sponsorChange() {
  window.location.href = '/admin/challenges?account=' + $("#form_account select").val();
}

function deleteAsset(row, asset_id) {
  $('#' + row).fadeOut();
  $.ajax({
    type: 'GET',
    url: '/admin/challenges/delete_asset?asset_id=' + asset_id,
    success: function(results) { 
      if (results == 'false') {
        $('#' + row).show();
        alert('There was an error deleting this Asset. Please contact support.');
      } else {
        $('#' + row).remove();
        // remove the table if there are no assets
        if ($('#assetsTable tr').length == 1) $('#assetsTable').fadeOut();
      }
    },
    failure: function(results) { 
      $('#' + row).show();
      alert('There was an error deleting this Asset. Please contact support.');
    }      
  });
}

function nextTab(elem) {
  $(elem + ' li.active')
    .next()
    .find('a[data-toggle="tab"]')
    .click();

  $('html, body').animate({
    scrollTop: $(elem).offset().top - 40
  }, 200);
}

function prevTab(elem) {
  $(elem + ' li.active')
    .prev()
    .find('a[data-toggle="tab"]')
    .click();
  $('html, body').animate({
    scrollTop: $(elem).offset().top - 40
  }, 200);
}

function validateForm() {

  var errors = [];
  var startDate = new Date($('#date-range-hidden-start').val());
  var endDate = new Date($('#date-range-hidden-end').val());

  if ($('#admin_challenge_name').val() == '')
    errors.push('Name');

  if (parseInt((endDate-startDate)/(24*3600*1000)) == 0) {
    errors.push('Start Date');
    errors.push('End Date');          
  }

  if (CKEDITOR.instances['admin_challenge_description'].getData() == '')
    errors.push('Overview');  

  if (CKEDITOR.instances['admin_challenge_requirements'].getData() == '')
    errors.push('Requirements');  

  if (errors.length > 0) {
    alert('The following fields are required: \n\n' + errors.join(', '))
    return false;
  } else {
    return true;
  }

}
  
$(function() {

  // Add new prize sets
  $('.add-new-prize-set').live('click', function(e) {
    $('#prize-set tbody').append('\
      <tr> \
        <td><input type="text" name="admin_challenge[prizes][][place]" /></td> \
        <td><input type="text" name="admin_challenge[prizes][][prize]" /></td> \
        <td><a class="btn btn-danger delete-prize-set"><span>Delete This Prize Set</span></a></td> \
      </tr>')

    $('#prize-set tbody > tr').jqTransform()

    e.preventDefault()
  })

  // Delete prize sets
  $('.delete-prize-set').live('click', function(e) {
    $(this).parents('tr').fadeOut().empty()
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

})