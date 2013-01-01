class MembersController < ApplicationController
  
  # note that we provide our own search service so that we have greater control
  # over the results; e.g. caching, endpoint configuration, result format, etc.
  def search
    @members = Member.search(params[:keyword])
    render json: @members, :callback => params[:callback]
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
