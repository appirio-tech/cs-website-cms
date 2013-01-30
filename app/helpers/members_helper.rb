module MembersHelper

	def leaderboard_place_decorator(place)
		if place < 4
			"p#{place}"
		end
	end

end
