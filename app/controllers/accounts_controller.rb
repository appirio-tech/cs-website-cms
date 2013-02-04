class AccountsController < ApplicationController
	before_filter :authenticate_user!

	def details
		@member = Member.find(current_user.username, { fields: 'id,name,profile_pic,address_line1' })
		puts @member.to_yaml
	end

	def payment_info

	end

	def school_and_work

	end

	def public_profile

	end

	def change_password

	end

	def challenges
		
	end

	def communities

	end

	def referred_members
		
	end

	def invite_friends
		
	end

end
