class Message < ApiModel

	attr_accessor :id, :name, :createddate, :to, :from, :subject, :status_from, :status_to, :replies, 
	:to__r, :from__r, :status, :display_user, :icon

  def self.api_endpoint
    "#{ENV['CS_API_URL']}/messages"
  end	

end