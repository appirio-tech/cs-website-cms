class Platform

	def self.stats
		JSON.parse(RestClient.get("#{ENV['CS_API_URL']}/stats"))['response']
	end

	def self.leaderboard(access_token, options = {:period => nil, :category => nil, :limit => nil})
		JSON.parse(RestClient.get("#{ENV['CS_API_URL']}/leaderboard?#{options.to_param}"))['response']
	end

end