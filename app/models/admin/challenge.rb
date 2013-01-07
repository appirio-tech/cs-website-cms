class Admin::Challenge
  include ActiveModel::Model

  STATUSES = ['Created', 'Completed', 'Hidden', 'Review', 'Submission', 'Winner Selected', 'No Winner Selected', 'On Hold - Pending Reviews']
  PRIZE_TYPES = ['Currency', 'Other']

  # Overrides the attr_accesssor class method so we are able to capture and
  # then save the defined fields as column_names
  def self.attr_accessor(*vars)
    @column_names ||= []
    @column_names.concat( vars )
    super
  end

  # Returns the previously defined attr_accessor fields
  def self.column_names
    @column_names
  end

  attr_accessor :winner_announced, :terms_of_service, :scorecard_type, :submission_details,
                :status, :start_date, :requirements, :name, :status, :end_date, :description,
                :reviewers, :categories, :prizes, :commentNotifiers, :reviewers_to_delete,
                :categories_to_delete, :prizes_to_delete, :commentNotifiers_to_delete, :assets,
                :challenge_type, :terms_of_service, :comments, :challenge_id,
                
                # these are fields from the challenge api that need to be there so we can
                # just "eat" the json and avoid the model from complaining that these
                # fields don't exist -- we might need to clean up the __r bits
                :attributes, :total_prize_money, :submissions, :usage_details, :is_open,
                :release_to_open_source, :post_reg_info, :prize_type, :discussion_board,
                :registered_members, :challenge_comments, :additional_info,
                :participating_members, :challenge_prizes__r,
                :top_prize, :id, :participants

  # Add validators as you like :)
  validates :name, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates_inclusion_of :status, in: STATUSES

  validate  do
    if start_date && end_date && winner_announced
      errors.add(:end_date, 'must be after start date') unless end_date > start_date
      errors.add(:winner_announced, 'must be after end date') unless winner_announced >= end_date.to_date
    end
  end

  # Return an object instead of a string
  def start_date
    Date.parse(@start_date) if @start_date
  end

  # Return an object instead of a string
  def end_date
    Date.parse(@end_date) if @end_date
  end

  # Return an object instead of a string
  def winner_announced
    Date.parse(@winner_announced) if @winner_announced
  end

  def categories
    @categories.delete_if {|n| n.blank?} if @categories
  end

  def assets
    @assets.delete_if {|n| n.blank?} if @assets
  end

  def statuses
    Admin::Challenge::STATUSES
  end

  # formats the object to conform to the api format
  # maybe we should use RABL for this one instead?
  def payload
    {
      challenge: {
        detail: {
          winner_announced: winner_announced,
          terms_of_service: terms_of_service,
          scorecard_type:"Sandbox Scorecard",
          submission_details: submission_details,
          status: status,
          start_date: start_date.to_time.iso8601,
          requirements: requirements,
          name: name,
          end_date: end_date.to_time.iso8601,
          description: description,
          comments: comments,
          challenge_type: challenge_type,
        },
        challenge_id: challenge_id,
        reviewers: reviewers.map {|name| {name: name}},
        categories: categories.map {|name| {name: name}},
        prizes: prizes,
        commentNotifiers: commentNotifiers.map {|name| {name: name}},
        assets: assets && assets.map {|filename| {filename: filename}},

        # TO BE IMPLEMENTED:
        # reviewers_to_delete: [{name: "mess"}, {name: "jeffdonthemic"}],
        # categories_to_delete: [{name: "java"}, {name: "heroku"}],
        # prizes_to_delete: [{place:2,points:222,prize:"122",value:1212}, {place:1,points:2120,prize:"1000",value:21212}],
        # commentNotifiers_to_delete: [{email: "jdouglas@appirio.com"}, {name: "mess"}],
      }
    }
  end

end

# {
#   "challenge" : {
#     "detail" : {
#       "winner_announced":"2015-05-17",
#       "terms_of_service":"Standard Terms & Conditions",
#       "scorecard_type":"Sandbox Scorecard",
#       "submission_details":"<em>&#39;Some submission details&#39;<br><br>Another double quoted stuff &quot;fdfdfd&quot;</em>",
#       "status":"Hidden",
#       "start_date":"2012-03-17T18:02:00.000+0000",
#       "requirements":"Hello this is a sample requirement with some interesting stuff like<br><br>Bullets<br><ul><li>Bull1</li><li>Bull2</li></ul>\n<div style=\"text-align: center; \">Links <br><br><a href=\"http://developer.force.com\" target=\"_blank\">http://developer.force.com<br></a><br><strong>Bold Text</strong></div>\n<br><strike><em>Crossed - Italics<br></em></strike><br><br>",
#       "name":"RSpec Challenge",
#       "status":"Planned",
#       "end_date":"2014-04-17T18:02:00.000+0000",
#       "description":"sample Description",
#       "comments":"My challenge comments",
#       "challenge_type":"Design"
#       }, 
#     "reviewers" : [{"name" : "mess"}, {"name" : "jeffdonthemic"}],
#     "categories" : [{"name" : "java"}, {"name": "heroku"}],
#     "prizes" : [{"place":2,"points":222,"prize":"122","value":1212}, {"place":1,"points":2120,"prize":"1000","value":21212}],
#     "commentNotifiers" : [{"email" : "jdouglas@appirio.com"}, {"name" : "mess"}],
#     "assets" : [{"filename" : "img.png"}, {"filename": "logo.jpg"}],
#     "reviewers_to_delete" : [{"name" : "mess"}, {"name" : "jeffdonthemic"}],
#     "categories_to_delete" : [{"name" : "java"}, {"name": "heroku"}],
#     "prizes_to_delete" : [{"place":2,"points":222,"prize":"122","value":1212}, {"place":1,"points":2120,"prize":"1000","value":21212}],
#     "commentNotifiers_to_delete" : [{"email" : "jdouglas@appirio.com"}, {"name" : "mess"}],
#     "assets_to_delete" : [{"filename" : "img.png"}, {"filename": "logo.jpg"}]
#   }
# }