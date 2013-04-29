class Community < ApiModel
  attr_accessor :name, :community_id, :about, :members, :community, :leaderboard, :challenges

  def self.api_endpoint
    "communities"
  end     

  def self.names
    @names ||= Community.all.map {|c| c.name}
  end  

end