require 'spec_helper'

describe Challenge do

  before(:all) do
    VCR.use_cassette "shared/public_oauth_token", :record => :all do
      ApiModel.access_token = RestforceUtils.access_token
    end    
    @challenge_id = 21
    VCR.use_cassette "models/member/find" do
      @challenge = Challenge.find @challenge_id
    end         
  end   

  describe "'Open' challenges" do
    it "should return challenges that are open" do
      VCR.use_cassette "models/challenge/all_open" do
        results = Challenge.open
        results.count.should > 0
      end
    end
  end   

  describe "'All' challenges" do
    it "should return at least 1 challenge" do
      VCR.use_cassette "models/challenge/all" do
        results = Challenge.all
        results.count.should > 0
      end
    end
  end   

  describe "'Recent' challenges" do
    it "should return at least 1 challenge" do
      VCR.use_cassette "models/challenge/recent" do
        results = Challenge.recent
        results.count.should > 0
      end
    end
  end     

  describe "Results overview" do
    it "should return the text of the overview" do
      VCR.use_cassette "models/challenge/results_overview" do
        results = @challenge.results_overview
        results.should_not be_nil
      end
    end
  end    

  describe "Find challenge" do
    it "should return the correct record" do
      VCR.use_cassette "models/challenge/find" do
        results = Challenge.find @challenge_id
        results.challenge_id.should == @challenge_id.to_s
      end      
    end  

    it "should have a collection of comments" do
      VCR.use_cassette "models/challenge/comments" do
        results = @challenge.comments
        results.count.should > 0
      end     
    end   

    it "should have a collection of participants" do
      VCR.use_cassette "models/challenge/participants" do
        results = @challenge.participants
        results.count.should == @challenge.participating_members
      end     
    end    

    it "should have a collection of scorecards" do  
      VCR.use_cassette "models/challenge/scorecards" do
        results = @challenge.scorecards
        results.count.should >= 0
      end   
    end   

    it "should have a collection of deliverables" do
      VCR.use_cassette "models/challenge/deliverables" do
        results = @challenge.submission_deliverables
        results.count.should >= 0
      end     
    end  

  end

  describe "Scorecard" do
    it "should return the scorecard questions" do
      VCR.use_cassette "models/challenge/all" do
        results = Challenge.scorecard_questions @challenge_id
        results.count.should > 0
      end
    end
  end   

  describe "A challenge" do
    it "should have a collection of comments" do
      @challenge.challenge_comments.count.should >= 0
    end

    it "should have a collection of category_names" do
      puts @challenge.category_names
      @challenge.category_names.count.should >= 0
    end    
  end    


end