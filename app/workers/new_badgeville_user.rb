class NewBadgeVilleUser
  include HTTParty 
  
  @queue = :new_badgeville_user
  def self.perform(access_token, username, email)

    # create the badgeville user
    Badgeville.create_user(username, email.downcase)
      
    #create the badgeville player
    player_id = Badgeville.create_player(username.downcase, email.downcase)
    
    unless player_id.nil?
      Badgeville.send_site_registration(player_id)
      # update sfdc with badgeville player id
      response = Member.http_put("members/#{username}", {"Badgeville_Id__c" => player_id})
      puts "[INFO][QUEUE] Updating #{username} in SFDC with Badgeville Id #{player_id}: #{response['success']}"
    else
      puts "[FATAL][QUEUE] Could not update #{username} with Badgeville Id. Player_Id is nil"
    end
    
  end
  
end