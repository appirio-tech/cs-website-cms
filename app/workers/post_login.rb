class PostLogin
  
  @queue = :post_login
  def self.perform(access_token, username, remote_ip)

    puts "====== running post login "
    puts "access_token: #{access_token}"
    puts "username: #{username}"
    puts "remote_ip: #{remote_ip}"

    ## update the member's country
    unless ['127.0.0.1', 'localhost'].include?(remote_ip)
      # get the member to see if they have selected a country before
      member = Member.find(username, fields: 'id,country')
      if member.country.nil?
        @geoip ||= GeoIP.new("#{Rails.root}/db/GeoIP.dat")    
        geo_data = @geoip.country(remote_ip)
        results = Member.http_put("members/#{username}", {"Country__c" => geo_data['country_name']})  unless geo_data.nil? 
      end
    end
    
  end
  
end