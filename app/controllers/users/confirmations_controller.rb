
class Users::ConfirmationsController < Devise::ConfirmationsController

  # GET /resource/confirmation?confirmation_token=abcdef
  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])

    if resource.errors.empty?
      process_referral resource.username
      process_marketing resource.username
      set_flash_message(:notice, :confirmed) if is_navigational_format?
      sign_in(resource_name, resource)

      respond_with_navigational(resource){ redirect_to after_confirmation_path_for(resource_name, resource) }
    else
      respond_with_navigational(resource.errors, :status => :unprocessable_entity){ render :new }
    end
  end

  private

    def process_referral(new_member_name)
      if cookies[:referral_referred_by]
        # send it to the queue
        Resque.enqueue(ProcessReferral, admin_access_token, cookies[:referral_referred_by], new_member_name) 
        # clean up
        cookies.delete :referral_referred_by
      end
    end

    def process_marketing(new_member_name)
      if cookies[:marketing_campaign_source] && cookies[:marketing_campaign_medium] && cookies[:marketing_campaign_name]
        # send it to the queue
        Resque.enqueue(MarketingUpdateNewMember, admin_access_token, new_member_name, cookies[:marketing_campaign_source], 
          cookies[:marketing_campaign_medium], cookies[:marketing_campaign_name]) 
        # clean up
        cookies.delete :marketing_campaign_source
        cookies.delete :marketing_campaign_medium
        cookies.delete :marketing_campaign_name
      end
    end    

end