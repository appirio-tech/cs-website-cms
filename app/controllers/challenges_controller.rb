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

  def search
    # nillify blank entries
    params[:categories].delete_if{|v| v.blank?} if params[:categories]
    params.delete_if{|k, v| v.blank? || v.empty?}

    # remove extra params taht rails adds
    params.delete_if{|k, v| ['utf8', 'action', 'controller'].include? k}
    
    # create the search object
    @search = Search::Search.new(params)

    # get a list of existing category names
    @category_names = Search::Category.all.map(&:display_name).uniq
    
    # show the filtered challenges (all challenges by default)
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

end
