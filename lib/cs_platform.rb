class CsPlatform

	def self.stats
		stats = Rails.cache.fetch('platform_stats', :expires_in => 60.minute) do
			JSON.parse(RestClient.get("#{ENV['CS_API_URL']}/stats"))['response']
		end
	end

	def self.tos(id)
		JSON.parse(RestClient.get("#{ENV['CS_API_URL']}/tos/#{id}"))['response']
	end	

	def self.leaderboard_month(access_token, options = {:period => nil, :category => nil, :limit => nil})
		leaderboard_month = Rails.cache.fetch('leaderboard_month', :expires_in => 60.minute) do
			JSON.parse(RestClient.get("#{ENV['CS_API_URL']}/leaderboard?#{options.to_param}"))['response']
		end
	end

	def self.leaderboard_year(access_token, options = {:period => nil, :category => nil, :limit => nil})
		leaderboard_year = Rails.cache.fetch('leaderboard_year', :expires_in => 60.minute) do
			JSON.parse(RestClient.get("#{ENV['CS_API_URL']}/leaderboard?#{options.to_param}"))['response']
		end
	end

	def self.leaderboard_alltime(access_token, options = {:period => nil, :category => nil, :limit => nil})
		leaderboard_alltime = Rails.cache.fetch('leaderboard_alltime', :expires_in => 60.minute) do
			JSON.parse(RestClient.get("#{ENV['CS_API_URL']}/leaderboard?#{options.to_param}"))['response']
		end
	end	

end