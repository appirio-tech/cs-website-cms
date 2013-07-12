class SendMessageToThurgood
  
  @queue = :send_message_to_thurgood
  def self.perform(participant_id, text)
  	Participant.new(:id => participant_id).send_message_to_thurgood_logger text
  end
  
end