require 'spec_helper'

describe Challenge do

  # get oauth tokens for different users
  before(:all) do
    @access_token = '00DK0000008yRYr!AQQAQE2tZRet.7DFEdaqamyod6ZcuSnlPkvDYbqlo4cW5YLYA0PmwwFj.L6BQRKd_ClsT8NPXmqrTiRtZ_Q4Jbp8jpaPGlev'
  end   

  describe "'Open' challenges" do
    it "should return challenge that are open" do
      VCR.use_cassette "models/challenge/all_open" do
        ApiModel.access_token = @access_token
        results = Challenge.all
        puts results.to_yaml
      end
    end
  end      

end