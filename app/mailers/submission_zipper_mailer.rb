class SubmissionZipperMailer < ActionMailer::Base
  default from: "CloudSpokes Team <support@cloudspokes.com>"
  
  def notify(email, challenge_id, zip_url)
    subject = "Your zip request for CS Challenge #{challenge_id} has been made"
    body = "You can download the zip file of all the submissions from #{zip_url}\n\nThank you."
    mail(to: email, subject: subject, body: body)
  end   
  
end