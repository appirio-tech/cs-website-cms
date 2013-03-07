$ ->
	this.processNewMessage = ->
		to = $('#to').val()
		subject = $('#subject').val()
		body = $('#body').val()
		if (to.length > 0 && subject.length > 0 && body.length > 0)
			body = body.replace(/\n\r?/g, '<br />')
			message = { to: to, subject: subject, body: body }
			$.ajax
				type: 'POST'
				beforeSend: (xhr) -> 
					xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))
				url: "/messages"
				data: { message: message }
				success: (data, textStatus, jqHXR) ->
					if data['success']
						window.location.replace('/messages/inbox?sent=true')
					else
						alert "Error sending message: #{data['message']}"
					false
				error: (jqXHR, textStatus, errorThrown) ->
					alert errorThrown
		false		

	this.processReply = (message_id) ->
		body = $('#body').val()
		if body.length > 0
			body = body.replace(/\n\r?/g, '<br />')		
			$.ajax
				type: 'POST'
				beforeSend: (xhr) -> 
					xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))
				url: "/messages/#{message_id}/reply"
				data: { body: body }
				success: (data, textStatus, jqHXR) ->
					window.location.reload(false)
					false
				error: (jqXHR, textStatus, errorThrown) ->
					alert textStatus
		false						