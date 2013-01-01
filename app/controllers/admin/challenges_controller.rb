class Admin::ChallengesController < ApplicationController
  # optionally, inherit from ::ProtectedController to gain any kind of protection
  # in a standard way; maybe username/password or refinery usertypes?

  def new
    @challenge = Admin::Challenge.new
  end

  def create
  end
end
