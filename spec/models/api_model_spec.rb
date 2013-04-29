require 'spec_helper'

class TestApiModel < ApiModel
  attr_accessor :id, :challenge_id, :name, :desc

  has_many :members

  def self.api_endpoint
    'challenges'
  end 
end

describe ApiModel do

  before(:all) do
    VCR.use_cassette "shared/public_oauth_token", :record => :all do
      ApiModel.access_token = RestforceUtils.access_token
    end   

    @model = TestApiModel.new({name: "test", desc: "description"})

  end    
  
  describe "All records" do
    it "should return at least one record" do
      VCR.use_cassette "models/api/all" do
        results = TestApiModel.all
        results.count.should >= 0
      end
    end
  end

  describe "Find record" do
    it "should return the correct record" do
      challenge_id = nil
      VCR.use_cassette "models/api/first" do
        challenge_id = TestApiModel.first.challenge_id
      end
      VCR.use_cassette "models/api/find" do
        results = TestApiModel.find challenge_id
        results.challenge_id.should == challenge_id
      end      
    end

    it "should return the correct record with specific keys" do
      challenge_id = nil
      VCR.use_cassette "models/api/first" do
        challenge_id = TestApiModel.first.challenge_id
      end
      VCR.use_cassette "models/api/find" do
        results = TestApiModel.find challenge_id, {fields: 'id,name'}
        puts results.to_yaml
        results.challenge_id.should == challenge_id
      end      
    end    
  end  

end