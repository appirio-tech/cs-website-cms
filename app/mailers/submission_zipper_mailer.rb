class SubmissionZipperMailer < ActionMailer::Base
  default from: "CloudSpokes Team <support@cloudspokes.com>"
  
  def notify(email, challenge_id, zip_url)
    subject = "Files for Challenge #{challenge_id}"
    body = "Your zip request for Challenge #{challenge_id} has been processed. You can download the zip file of all the submissions from #{zip_url}\n\nThank you."
    mail(to: email, subject: subject, body: body)
  end   
  
end