class MashathonController < ApplicationController
  before_filter :authenticate_user!, except: [:result]

  def index
    @mashathon = Mashathon.find_by_user(current_user)
    render layout: false  
  end

  # {api:"facebook"}
  def pick
    mashathon = Mashathon.find_by_user(current_user)
    api = mashathon.pick_api

    render json: {api: api}
  end

  def result
    @mashathons = Mashathon.all
    render layout: false      
  end
end
