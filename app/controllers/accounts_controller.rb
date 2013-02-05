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
		fields = 'id,name,preferred_payment,paperwork_received,paperwork_sent,paperwork_year,paypal_payment_address'
		@member = Member.find(current_user.username, fields: fields)

		@payments = @member.payments
		@paid_payments = @payments.select(&:paid?)
		@outstanding_payments = @payments - @paid_payments
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
