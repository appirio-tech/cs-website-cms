class Admin::ChallengesController < ApplicationController
  # optionally, inherit from ::ProtectedController to gain any kind of protection
  # in a standard way; maybe username/password or refinery usertypes?

  def new
    @challenge = Admin::Challenge.new
  end

  def create
    @challenge = Admin::Challenge.new(params[:admin_challenge])
    render json: @challenge.payload
  end
end
