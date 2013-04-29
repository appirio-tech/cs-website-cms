require 'spec_helper'

describe Participant do

  before(:all) do
    VCR.use_cassette "shared/public_oauth_token", :record => :all do
      ApiModel.access_token = RestforceUtils.access_token
    end   

    VCR.use_cassette "shared/open_challenge", :record => :all do
      @challenge = Challenge.open.first
    end 

    @rspec_test_membername = (0...6).map{65.+(rand(26)).chr}.join+rand(100).to_s

    # create the rspec testing user
    VCR.use_cassette "shared/rspec_test_member" do
      params = {email: "#{@rspec_test_membername}@test.cloudspokes.com", 
        username: @rspec_test_membername, password: '11111111a', 
        password_confirmation: '11111111a'}
      @account = Account.new(User.new(params))      
      results = @account.create params
      puts "[SETUP]New testing member '#{@rspec_test_membername}' - #{results.message}"
    end      

  end   

  describe "Participant" do
    it "should successfully watch a member for a challenge" do
      VCR.use_cassette "models/participant/watching" do
        results = Participant.change_status(@challenge.challenge_id, 
          @rspec_test_membername, {:status => 'Watching'})
        results.success.should == 'true'
      end
    end

    it "should successfully register a member for a challenge" do
      VCR.use_cassette "models/participant/register" do
        results = Participant.change_status(@challenge.challenge_id, 
          @rspec_test_membername, {:status => 'Registered'})
        results.success.should == 'true'
      end
    end

    it "should return participant by member and challenge" do
      VCR.use_cassette "models/participant/find_by_member" do
        results = Participant.find_by_member(@challenge.challenge_id, @rspec_test_membername)
        results.has_submission.should_not be_nil
        results.member.should_not be_nil
        results.id.should_not be_nil
        results.override_submission_upload.should_not be_nil
        results.challenge.should_not be_nil
      end
    end

    it "should return participant by participant id" do
      VCR.use_cassette "models/participant/find_by_member" do
        results = Participant.find_by_member(@challenge.challenge_id, @rspec_test_membername)
        @participant_id = results.id
      end
      VCR.use_cassette "models/participant/find_by_id" do
        results = Participant.find @participant_id
        results.has_submission.should_not be_nil
        results.member.should_not be_nil
        results.id.should_not be_nil
        results.challenge.should_not be_nil
      end      
    end    

  end      

end