class ApplicationController < ActionController::Base
  protect_from_forgery

  def show_welcome_page?
    #overriding refinery initialization wizard behavior, so unpopulated test
    #database will successfully run.
    false
  end


  private

  def after_sign_in_path_for(user)
    "/challenges"
  end  
end
