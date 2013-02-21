class InviteEmailSender
  
  @queue = :invite_email_queue
  def self.perform(membername, profile_pic, email)
    mail = MemberMailer.invite(membername, profile_pic, email).deliver   
  end
  
end