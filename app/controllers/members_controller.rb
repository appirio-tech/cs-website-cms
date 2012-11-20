class MembersController < ApplicationController
  def search
  end

  def challenges
  end

  def payments
  end

  def recommendations
  end

  def create_recommendations
  end

  def index
    @members = Member.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @members }
    end
  end

  def show
    @member = Member.find(params[:id])
  end

  def update
  end
end
