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

	$('#register-modal input[type="submit"]').click ->

		username = $('#input-name').val()
		email = $('#input-email').val()
		password = $('#input-pwd').val()
		password_again = $('#input-pwd-again').val()

		$('#register-modal input').each ->
				if($(this).val()=='')
					$(this).parents('.control-group').addClass('error')
					if($(this).parents('.controls').find('.help-inline').length==0)
						$(this).parents('.controls').append('<div class="help-inline">*All fields are required.</div>')
					else
						$(this).parents('.controls').find('.help-inline').html("*All fields are required.")
				else
					$(this).parents('.control-group').removeClass('error')
					if($(this).parents('.controls').find('.help-inline').length!=0)
						$(this).parents('.controls').find('.help-inline').remove()

			if($('#register-modal input[type=checkbox]:checked').length==0)
				checkbox = $('#register-modal input[type=checkbox]')
				checkbox.parents('.control-group').addClass('error')
				if(checkbox.parents('.controls').find('.help-inline').length==0)
					checkbox.parents('.controls label').append('<div class="help-inline">You must agree to the terms of service.</div>')
				else
					checkbox.parents('.controls').find('.help-inline').html("You must agree to the terms of service.")

			password_container = $('#input-password-container')
			password_again_container = $('#input-password-again-container')	

			# check the password length and if ok make sure they match
			if(password.length < 8)
				password_container.parents('.control-group').addClass('error')
				password_container.append('<div class="help-inline">8 characters with letters & numbers</div>')
			else
				if(password != password_again)
					password_container.parents('.control-group').addClass('error')
					password_container.append('<div class="help-inline">Passwords do not match</div>')
					password_again_container.parents('.control-group').addClass('error')
					password_again_container.append('<div class="help-inline">Passwords do not match</div>')				

			if($('#register-modal .error').length==0)
				$.ajax
					type: 'POST'
					url: '/users'
					data: { user: {username: username, email: email, password: password, password_confirm: password_again} }
					success: (results, textStatus, jqHXR) ->
						console.log results
						if (results.indexOf('email') != -1)
							email_container = $('#input-email-container')
							email_container.parents('.control-group').addClass('error')
							email_container.append('<div class="help-inline">'+results+'</div>')	
						# catch Username and username
						if (results.indexOf('sername') != -1)
							username_container = $('#input-username-container')
							username_container.parents('.control-group').addClass('error')
							username_container.append('<div class="help-inline">'+results+'</div>')
						if (results.indexOf('assword') != -1)
							if results.indexOf('INVALID_NEW_PASSWORD: Your password m' != -1)
								results = "M#{results.slice(37)}"
							password_container = $('#input-password-container')
							password_container.parents('.control-group').addClass('error')
							password_container.append('<div class="help-inline">'+results+'</div>')						
					error: (jqXHR, textStatus, errorThrown) ->	
						console.log textStatus
			false