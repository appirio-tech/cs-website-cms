class AccountsController < ApplicationController
	before_filter :authenticate_user!

	def update
		Member.put(current_user.username, params[:account])
		redirect_to :back
	end

	def details
		fields = 'id,name,profile_pic,first_name,last_name,email,address_line1,address_line2,city,zip,state,phone_mobile,time_zone,country'
		@member = Member.find(current_user.username, fields: fields)
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
