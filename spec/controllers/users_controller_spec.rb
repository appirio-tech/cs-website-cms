require "spec_helper"

describe Users::SessionsController do

  before :each do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe '#new' do
    it "renders the new template" do
      get :new
      response.should be_success
      response.should render_template("users/sessions/new")
    end
  end

end