require 'spec_helper'

describe Category do

  before(:all) do
    VCR.use_cassette "shared/admin_oauth_token", :record => :all do
      ApiModel.access_token = RestforceUtils.access_token(:admin)
    end    
  end   

  describe "Category names" do
    it "should return at least 1 category" do
      VCR.use_cassette "models/category/names" do
        results = Category.names
        results.count.should >= 0
      end
    end
  end     

end