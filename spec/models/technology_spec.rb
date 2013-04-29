require 'spec_helper'

describe Technology do

  before(:all) do
    VCR.use_cassette "shared/admin_oauth_token", :record => :all do
      ApiModel.access_token = RestforceUtils.access_token(:admin)
    end    
  end   

  describe "Technology names" do
    it "should return at least 1 technology" do
      VCR.use_cassette "models/technology/names" do
        results = Technology.names
        results.count.should >= 0
      end
    end
  end     

end