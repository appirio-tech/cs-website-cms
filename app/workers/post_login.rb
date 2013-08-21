class PostLogin
  
  @queue = :post_login
  def self.perform(username, remote_ip)

    member = Member.find(username, fields: 'id,name,username,email,country')
    member.update_country_from_ip(remote_ip)
    member.update_login_location_from_ip(remote_ip)
    member.update_last_login
        
  end
  
end