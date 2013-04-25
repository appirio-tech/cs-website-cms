class ApplicationController < ActionController::Base
  protect_from_forgery

  rescue_from ApiExceptions::EntityNotFoundError, :with => :entity_not_found
  rescue_from ApiExceptions::WTFError, :with => :something_bad_happened
  rescue_from ApiExceptions::AccessDenied, :with => :entity_access_denied

  before_filter :set_access_token
  before_filter :set_gon_variables
  before_filter :get_platform_stats
  before_filter :miniprofiler

  def set_access_token
    ApiModel.access_token = current_access_token
  end    

  def set_gon_variables
    gon.cs_api_url = ENV['CS_API_URL']
    gon.website_url = ENV['WEBSITE_URL']
  end    

  def get_platform_stats
    @platform_stats = CsPlatform.stats  
  end   

  def miniprofiler
    puts 'running miniprofiler'
    if current_user && current_user.email == 'jdouglas@appirio.com'
      Rack::MiniProfiler.authorize_request
    end
  end     

  def show_welcome_page?
    false
  end

  def entity_not_found(exception)
    redirect_to '/not_found'
  end

  def entity_access_denied
    redirect_to '/access_denied'
  end    

  def something_bad_happened
    redirect_to '/bad'
  end      

  def guest_access_token
    User.guest_access_token
  end  

  def admin_access_token
    User.admin_access_token
  end    

  private

    def after_sign_in_path_for(resource)
      request.env['omniauth.origin'] || stored_location_for(resource) || challenges_path
    end  

    def current_access_token
      if current_user.nil?
        guest_access_token
      else
        if current_user.access_token
          # temp
          current_user.last_access_token_refresh_at = Date.yesterday if current_user.last_access_token_refresh_at.nil?
          logger.info "[APPLICATION] Has Access Token expired?: #{Time.now.utc} > 60minutes past #{current_user.last_access_token_refresh_at} - expired #{Time.now.utc > 60.minutes.since(current_user.last_access_token_refresh_at)}"
          # check and see if it's an hour old
          if Time.now.utc > 60.minutes.since(current_user.last_access_token_refresh_at)
            current_user.update_with_sfdc_info     
          else
            current_user.access_token
          end
        else
          current_user.update_with_sfdc_info
        end
      end
    end 

end
