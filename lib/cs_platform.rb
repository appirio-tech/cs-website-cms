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
		leaderboard_month = Rails.cache.fetch('leaderboard_month', :expires_in => 3.minute) do
			puts "===== calling leaderboard_month"
			Rails.logger.info "===== calling leaderboard_month with options #{options.to_yaml}"
			JSON.parse(RestClient.get("#{ENV['CS_API_URL']}/leaderboard?#{options.to_param}"))['response']
		end
	end

	def self.leaderboard_year(access_token, options = {:period => nil, :category => nil, :limit => nil})
		leaderboard_year = Rails.cache.fetch('leaderboard_year', :expires_in => 3.minute) do
			puts "===== calling leaderboard_year"
			Rails.logger.info "===== calling leaderboard_year with options #{options.to_yaml}"			
			JSON.parse(RestClient.get("#{ENV['CS_API_URL']}/leaderboard?#{options.to_param}"))['response']
		end
	end

	def self.leaderboard_alltime(access_token, options = {:period => nil, :category => nil, :limit => nil})
		leaderboard_alltime = Rails.cache.fetch('leaderboard_alltime', :expires_in => 3.minute) do
			puts "===== calling leaderboard_alltime"
			Rails.logger.info "===== calling leaderboard_alltime with options #{options.to_yaml}"				
			JSON.parse(RestClient.get("#{ENV['CS_API_URL']}/leaderboard?#{options.to_param}"))['response']
		end
	end	

end