class AccountsController < ApplicationController
	before_filter :authenticate_user!

	def update
    params[:account].delete("years_of_experience") if params[:account][:years_of_experience__c].blank?
    
    response = Member.put(current_user.username, params[:account])
    if response.success == "false"
      flash[:alert] = "Failed to update, reason : #{response.message}"
    else
      flash[:notice] = "Updated successfully"
    end
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
    fields = 'id,name,company,school,years_of_experience,work_status,shirt_size,age_range,gender'
    @member = Member.find(current_user.username, fields: fields)
	end

	def public_profile

	end

	def change_password

	end

	def challenges
    @followed_challenges = []
    @active_challenges   = []
    @past_challenges     = []

    # Sort challenges depending of the end date or status
    member = Member.find current_user.username
    member.challenges.each do |challenge|
    	if challenge.active?
    		status = challenge.participants.first.status
    		if status == "Watching"
    			@followed_challenges << challenge
    		else
    			@active_challenges << challenge
    		end
    	else
    		@past_challenges << challenge
    	end
    end
	end

	def communities
		@communities = Community.all
	end

	def referred_members
    @member = Member.find(current_user.username)		
    @referrals = @member.referrals
	end

	def invite_friends
		if request.post?
			params[:emails].each do |email|
				puts "send invitation email to #{email}"
				# Resque.enqueue(InviteEmailSender, current_user.username, email.second)
			end
			flash.now[:notice] = 'Your invites have been sent!'
		end		
	end

end
