require 'spec_helper'

=begin
set up jeffdonthemic with recommendations, payment, referrals,
inbox and sent messages, and all types of past and present challenges
=end

describe Member do

  before(:all) do
    VCR.use_cassette "shared/public_oauth_token", :record => :all do
      ApiModel.access_token = RestforceUtils.access_token
    end    
    VCR.use_cassette "models/member/find_jeffdonthemic" do
      @member = Member.find 'jeffdonthemic'
    end         
  end    

  describe "Find member" do
    it "should return the correct member" do
      VCR.use_cassette "models/member/find_#{@member.name}" do
        results = Member.find @member.name
        results.name.should == @member.name
      end      
    end
    it "should return the correct member with specific keys" do
      VCR.use_cassette "models/member/find_#{@member.name}_keys" do
        results = Member.find @member.name, {fields: 'id,name'}
        results.name.should == @member.name
        # should not have this key
        results.profile_pic.should be_nil
      end      
    end
  end    

  describe "A member" do
    it "should have recommendations" do  
      VCR.use_cassette "models/member/recommendations" do
        @member.recommendations.count.should > 0
      end    
    end  
    it "should have challenges" do  
      VCR.use_cassette "models/member/challenges" do
        @member.challenges.count.should > 0
      end    
    end     
    it "should have payments" do  
      VCR.use_cassette "models/member/payments" do
        @member.payments.count.should > 0
      end    
    end  
    it "should have refferals" do  
      VCR.use_cassette "models/member/refferals" do
        @member.referrals.count.should > 0
      end    
    end      
  end   

  describe "Member challenges" do
    it "should return a collection of active challenges" do
      VCR.use_cassette "models/member/active_challenges" do
        @member.active_challenges.count.should > 0     
      end      
    end  

    it "should return a collection of watching challenges" do
      VCR.use_cassette "models/member/watching_challenges" do
        @member.watching_challenges.count.should > 0     
      end      
    end  

    it "should return a collection of past challenges" do
      VCR.use_cassette "models/member/past_challenges" do
        @member.past_challenges.count.should > 0     
      end      
    end      
  end       

  describe "Logintype" do
    it "should return the correct type of login" do
      VCR.use_cassette "models/member/logintype_#{@member.name}" do
        results = Member.login_type @member.name
        results.should == 'Github'
      end      
    end  
  end     

  describe "Messages" do
    it "should return a collection of messages in the inbox" do   
      VCR.use_cassette "models/member/inbox_#{@member.name}" do
        @member.inbox.count.should > 0
      end         
    end
    it "should return a collection of sent messages" do   
      VCR.use_cassette "models/member/from_#{@member.name}" do
        @member.from.count.should > 0
      end         
    end    
  end

end