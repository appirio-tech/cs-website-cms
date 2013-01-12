class ProtectedController < ApplicationController
  before_filter :authenticate_user!
  def index
  	logger.info recent = Challenge.test
  	render :text => recent.count
  end
end
