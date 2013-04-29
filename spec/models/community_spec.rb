require 'spec_helper'

describe Community do

  before(:all) do
    VCR.use_cassette "shared/admin_oauth_token", :record => :all do
      ApiModel.access_token = RestforceUtils.access_token(:admin)
    end    
  end   

  describe "'All' communities" do
    it "should return at least 1 community" do
      VCR.use_cassette "models/community/all" do
        results = Community.all
        results.count.should >= 0
      end
    end
  end 

  describe "Community names" do
    it "should return at least 1 community" do
      VCR.use_cassette "models/community/names" do
        results = Community.names
        results.count.should >= 0
      end
    end
  end     

end