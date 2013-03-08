class MessageBox

	attr_reader :inbox_unread, :to_messages, :from_messages

	def initialize(membername, to_messages, from_messages)
		@membername = membername
		@inbox_unread = 0
		@to_messages = process_messages(to_messages, :inbox)
		@from_messages = process_messages(from_messages, :sent)
	end

	def to_s
		"#{@processed_messages.count.to_s} #{@type} messages for #{@membername}. #{@inbox_unread} inbox_unread." 
	end

	private

		def process_messages(messages, type)
			processed_messages = []
			messages.each do |m|
				new_message = {}
				new_message['id'] = m.id
				new_message['datetime'] = m.createddate
				new_message['subject'] = m.subject
				new_message['replies'] = m.replies.to_i

				if @membername.casecmp(m.to__r.name)
					new_message['display_user'] = m.from__r.name
					new_message['profile_pic'] = m.from__r.profile_pic
				elsif @membername.casecmp(m.from__r.name)
					new_message['display_user'] = m.to__r.name
					new_message['profile_pic'] = m.to__r.profile_pic
				end	

				if type.eql?(:inbox)
					if @membername.casecmp(m.to__r.name)
						new_message['status'] = m.status_to.downcase
					else
						new_message['status'] = m.status_from.downcase
					end
					@inbox_unread = @inbox_unread + 1 if new_message['status'].eql?('unread')
				elsif @type.eql?(:sent)
					# if we are look in the sent tab, always show the recipient's status
					new_message['status'] = m.status_to.downcase
				end			
				processed_messages << new_message
			end
			processed_messages
		end

end