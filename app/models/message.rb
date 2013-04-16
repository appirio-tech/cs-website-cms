class Message < ApiModel

	attr_accessor :id, :name, :to, :from, :subject, :status_from, :status_to, :replies, 
	:to__r, :from__r, :status, :display_user, :icon, :messages, :createddate, :body

  def initialize(params={})
    params['messages'] = params.delete('private_message_texts__r') if params['private_message_texts__r']

    super(params)
  end	

  def self.api_endpoint
    "messages"
  end	 

  def create
    body = {:data => {:to => self.to, :from => self.from, 
      :subject => self.subject, :body => self.body}}
    self.class.http_post("messages", body)
  end     

  def reply
    body = {:data => {:to => self.to, :from => self.from, 
      :subject => self.subject, :body => self.body}}
    self.class.http_post("messages/#{self.id}/reply", body)
  end     

  def mark_as_read(params)
    self.class.http_put("messages/#{self.id}", { 'data' => params })
  end     

end