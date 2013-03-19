class CsPlatform

	def self.stats
		stats = Rails.cache.fetch('platform_stats', :expires_in => 30.minute) do
			JSON.parse(RestClient.get("#{ENV['CS_API_URL']}/stats"))['response']
		end
	end

	def self.tos(id)
		JSON.parse(RestClient.get("#{ENV['CS_API_URL']}/tos/#{id}"))['response']
	end	

	def self.leaderboard_month(access_token, options = {:period => nil, :category => nil, :limit => nil})
		JSON.parse(RestClient.get("#{ENV['CS_API_URL']}/leaderboard?#{options.to_param}"))['response']
	end

	def self.leaderboard_year(access_token, options = {:period => nil, :category => nil, :limit => nil})
		JSON.parse(RestClient.get("#{ENV['CS_API_URL']}/leaderboard?#{options.to_param}"))['response']
	end

	def self.leaderboard_alltime(access_token, options = {:period => nil, :category => nil, :limit => nil})
		JSON.parse(RestClient.get("#{ENV['CS_API_URL']}/leaderboard?#{options.to_param}"))['response']
	end	

	def self.leaderboard_referral(access_token)
		JSON.parse(RestClient.get("#{ENV['CS_API_URL']}/leaderboard/referral"))['response']
	end		

end