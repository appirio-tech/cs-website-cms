class Platform

	def self.stats
		JSON.parse(RestClient.get("#{ENV['CS_API_URL']}/stats"))['response']
	end

  # def self.get_leaderboard(access_token, options = {:period => nil, :category => nil, :limit => nil})
  #   set_header_token(access_token) 
  #   request_url  = ENV['SFDC_REST_API_URL'] + '/leaderboard?1=1'
  #   request_url += ("&period=#{esc options[:period]}") unless options[:period].nil?
  #   request_url += ("&category=#{esc options[:category]}") unless options[:category].nil?
  #   request_url += ("&limit=#{options[:limit]}") unless options[:limit].nil?
  #   leaderboard =  get(request_url)
  #   #sort by total_money
  #   leaderboard.sort_by! { |key| key['total_money'].to_i }
  #   # reverse the order so the largest is at the top
  #   leaderboard.reverse!
  #   # add a rank to each one
  #   rank = 1
  #   leaderboard.each do |record| 
  #     record.merge!({'rank' => rank})
  #     rank = rank + 1
  #   end
  # end	

	def self.leaderboard
		JSON.parse(RestClient.get("#{ENV['CS_API_URL']}/leaderboard"))['response']
	end

end