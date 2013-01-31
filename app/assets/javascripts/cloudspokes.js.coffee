$ ->
	$('#forgot-password-modal button.btn[type="submit"]').click ->
		$('#forgot-password-modal .reset-results').html('<p>Processing....</p>')
		username = $('#reset-username').val()
		$.ajax
		  type: 'POST'
		  url: '/users/password'
		  data: { username: username }
		  success: (data, textStatus, jqHXR) ->
		    $('#forgot-password-modal .reset-results').html('<p>' + data + '</p>')
		    false
		  error: (jqXHR, textStatus, errorThrown) ->	
			  $('#forgot-password-modal .reset-results').html('<p>Sorry! We could not process your request: ' + errorThrown + '</p>')  
		false