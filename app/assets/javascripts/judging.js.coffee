$ ->
	@addJudge = (challenge_id) ->
		id = "signup-"+challenge_id
		document.getElementById(id).innerHTML = 'Processing request...'
		$.ajax
			type: 'GET'
			url: '/judging/add_judge/'+challenge_id
			success: (results, textStatus, jqHXR) ->
				document.getElementById(id).innerHTML = results