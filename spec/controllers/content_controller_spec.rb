require 'spec_helper'

describe ContentController do

  describe "GET 'forums_authenticate'" do
    it "returns http success" do
      get 'forums_authenticate'
      response.should be_success
    end
  end

end
