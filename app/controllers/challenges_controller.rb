class ChallengesController < ApplicationController
  def closed
    @challenges = Challenge.closed
  end

  def recent
    @challenges = Challenge.closed
  end

  def comments
  end

  def registrants
    @participants = Challenge.find(params[:id]).participants
  end

  def survey
  end

  def index
    @challenges = Challenge.all
  end

  def show
    @challenge = Challenge.find(params[:id])
  end

  def update
  end

  def show_search
    @category_names = Search::Category.all.map(&:display_name).uniq
    @search = session[:search] || Search::Search.new
    @challenges = Search::Challenge.filter(@search)
  end

  def show_populate
  end

  def populate
    json = JSON.parse(params[:json])
    json.each do |j|
      challenge = Search::Challenge.parse(j)
      challenge.save
    end
  end

  def search
    # nillify blank entries
    params[:search_search].delete_if{|k, v| v.blank?}
    params[:search_search][:categories].delete_if{|v| v.blank?}
    session[:search] = Search::Search.new(params[:search_search])
    redirect_to search_searches_path
  end

end
