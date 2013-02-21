class MemberMailer < ActionMailer::Base
  default from: "CloudSpokes Team <support@cloudspokes.com>"
  
  def invite(membername, profile_pic, email)
    @membername = membername
    @profile_pic = profile_pic
    mail(:to => email, :subject => "#{membername.camelcase} invites you to join CloudSpokes!")
  end   
  
end