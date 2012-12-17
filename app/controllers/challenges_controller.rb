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
    search_params = cleanup(params)

    # create the search object
    @search = Search::Search.new(search_params)

    # get a list of existing category names
    @category_names = Search::Category.all.map(&:display_name).uniq
    
    # show the filtered challenges (all challenges by default)
    @challenges = Search::Challenge.filter(@search)
  end

  # we post then redirect so that we have a "clean" url at the end.
  def create_search
    search_params = cleanup(params)
    redirect_to search_searches_path(search_params)
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

private

  # Cleans up the parameters by removing blank entries and other default params
  # that rails adds in by default. This results in a rather "clean" url.
  def cleanup(p)
    pclone = p.clone

    # nillify blank entries
    pclone[:categories].delete_if{|v| v.blank?} if pclone[:categories]
    pclone.delete_if{|k, v| v.blank? || v.empty?}

    # remove extra params that rails adds
    pclone.delete_if{|k, v| ['utf8', 'action', 'controller'].include? k}

    # TODO: transform the categories params to a comma separated list
  end    

end
