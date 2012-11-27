class ApplicationController < ActionController::Base
  protect_from_forgery

  def show_welcome_page?
    #overriding refinery initialization wizard behavior, so unpopulated test
    #database will successfully run.
    false
  end
end
