class PostUserCreate
  include HTTParty 
  
  @queue = :post_user_create
  def self.perform(user)

    member = Member.find(user['username'], { fields: 'id,email,name' })
    member.create_badgeville_account

  end
  
end