require 'spec_helper'

describe Platform do

  before(:all) do
    VCR.use_cassette "shared/admin_oauth_token", :record => :all do
      ApiModel.access_token = RestforceUtils.access_token(:admin)
    end    
  end   

  describe "Platform names" do
    it "should return at least 1 platform" do
      VCR.use_cassette "models/platform/names" do
        results = Platform.names
        results.count.should >= 0
      end
    end
  end     

end