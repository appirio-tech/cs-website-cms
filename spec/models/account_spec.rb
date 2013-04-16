require 'spec_helper'

describe Account do

  before(:all) do
    VCR.use_cassette "shared/public_oauth_token", :record => :all do
      ApiModel.access_token = RestforceUtils.access_token
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

  describe "Create account" do
    it "should create an account successfully" do
      create_username = (0...10).map{65.+(rand(26)).chr}.join+rand(100).to_s
      VCR.use_cassette "models/account/create_successfully" do
        params = {email: "#{create_username}@test.cloudspokes.com", 
          username: create_username, password: '11111111a', 
          password_confirmation: '11111111a'}
        account = Account.new(User.new(params))      
        results = account.create params
        results.username.should == create_username
        results.success.should == 'true'
        results.message.should == 'Member created successfully.'
      end
    end
  end    

  describe "Activate account" do
    it "should activate an account successfully" do
      VCR.use_cassette "models/account/activiate_successfully" do
        results = @account.activate
        results.should be_true
      end
    end

    it "should return false if no member found" do
      params = {email: "baduser@test.cloudspokes.com", 
        username: 'idonotexist', password: '11111111a', 
        password_confirmation: '11111111a'}
      bad_account = Account.new(User.new(params))  
      VCR.use_cassette "models/account/activiate_unseccessful" do
        results = bad_account.activate
        results.should be_false
      end
    end    
  end 

  describe "Find account" do
    it "should find a CloudSpokes account successfully" do
      VCR.use_cassette "models/account/find_cloudspokes_member" do
        results = Account.find_by_service(@rspec_test_membername, 'cloudspokes')
        results.username.should == @rspec_test_membername
        results.success.should == 'true'
        results.sfdc_username.downcase.should == "#{@rspec_test_membername.downcase}@m.cloudspokes.com.sandbox"
        results.email.downcase.should == @account.user.email.downcase
        results.accountid.should be_nil
      end
    end
  end  

  describe "Authenticate" do
    it "should log a user in" do
      VCR.use_cassette "models/account/authenticate_success" do
        results = @account.authenticate @account.user.password
        results.success.should == 'true'
        results.message.should == "Successful sfdc login."
        results.access_token.should_not be_nil
      end
    end
  end  

  describe "Marketing update" do
    it "should change the member's marketing info" do
      source = 'some source' 
      medium = 'some medium'
      name = 'campaign name'
      VCR.use_cassette "models/account/marketing_success" do
        results = @account.process_marketing(source, medium, name)
        results.success.should be_true
        results.message.should == "#{@rspec_test_membername} updated with marketing info. No matching community."
      end
    end
  end 

  describe "Process referral" do
    it "should update referral successfully" do
      VCR.use_cassette "models/account/process_referral" do
        results = @account.process_referral('mess')
        results.success.should be_true
      end
    end
  end      

  describe "Account password" do
    it "should update the token successfully" do
      VCR.use_cassette "models/account/update_token" do
        results = @account.update_password_token('sometoken')
        results.success.should == 'true'
        results.message.should == 'Passcode successfully updated.'
      end
    end

    it "should should change the password the password" do
      # first change the token so
      VCR.use_cassette "models/account/update_token_for_password" do
        @account.update_password_token('sometoken')
      end      
      VCR.use_cassette "models/account/update_password" do
        results = @account.update_password('sometoken','99999999q')
        results.success.should == 'true'
        results.message.should == 'Password changed successfully.'
      end
    end    
  end    

end