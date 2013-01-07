describe Account do
  let(:password) { "zfaLaeebWGr2Yd75abq3" }
  let(:username) { "testuser" }
  let(:user) { User.create(email: "test@email.com", username: username, password: password, password_confirmation: password) }
  let(:account) { Account.new(user) }

  describe "#create" do
    subject {
      VCR.use_cassette vcr_path do
        account.create
      end
    }

    context "with valid user" do
      let(:vcr_path) { "models/account/create" }

      its(:success) { should == "true" }
      its(:username) { should == user.username }
      its(:sfdc_username) { should be_present }
    end

    context "with easy password" do
      let(:easy_password_user) { User.create(email: "easypass@email.com", username: "easypass", password: "password", password_confirmation: "password") }
      let(:account) { Account.new(easy_password_user) }
      let(:vcr_path) { "models/account/create_with_easy_password" }

      its(:success) { should == "false" }
      its(:message) { should == "INVALID_NEW_PASSWORD: Your password cannot be easy to guess. Please choose a different one." }
    end

    context "with duplicated user" do
      let(:vcr_path) { "models/account/create_with_duplicates" }

      its(:success) { should == "false" }
      its(:message) { should == "Username testuser is not available." }
    end
  end

  describe "#data_for_create" do
    subject { account.send(:data_for_create) }

    it { subject[:email].should == user.email }
    it { subject[:username].should == user.username }
    it { subject[:password].should == user.password }
    it { subject[:provider].should be_blank }

    context "when user is signed up with third-party" do
      before(:each) do
        user.authentications.create(:provider => "facebook", :uid => "23483234")
      end

      it { subject[:provider].should == "facebook" }
      it { subject[:name].should == user.username }
      it { subject[:provider_username].should == user.username }
      it { subject[:password].should be_blank }
    end
  end


  describe "#authenticate" do
    subject {
      VCR.use_cassette vcr_path do
        account.authenticate(password)
      end
    }

    context "with valid password" do
      let(:vcr_path) { "models/account/authenticate" }

      its(:success) { should == "true" }
      its(:access_token) { should be_present }
    end

    context "with invalid password" do
      let(:vcr_path) { "models/account/authenticate_with_invalid_password" }
      let(:password) { "invalid" }

      its(:success) { should == "false" }      
      its(:message) { should == "authentication failure - Invalid Password"}
    end
  end


  describe ".find" do
    subject {
      VCR.use_cassette vcr_path do
        Account.find(username)
      end
    }

    context "with valid username" do
      let(:vcr_path) { "models/account/find" }      

      its(:success) { should == "true" }
      its(:username) { should == username }
      its(:sfdc_username) { should be_present }
      its(:profile_pic) { should be_present }
      its(:email) { should be_present }
    end

    context "with invalid username" do
      let(:vcr_path) { "models/account/find_with_invalid_name" }      
      let(:username) { "invalid" }

      its(:success) { should == "false" }
      its(:message) { should == "CloudSpokes managed member not found for invalid." }
    end
  end


  describe "#reset_password" do
    subject {
      VCR.use_cassette vcr_path do
        account.reset_password
      end
    }

    context "with valid username" do
      let(:vcr_path) { "models/account/reset_password" }      
      
      its(:success) { should == "true" }
    end
  end

  describe "#update_password" do
    let(:new_password) { "mwieruwpoijlwfihe" }
    subject {
      VCR.use_cassette vcr_path do
        account.update_password(passcode, new_password)
      end
    }

    # TODO : with valid passcode
    
    context "with invalid passcode" do
      let(:vcr_path) { "models/account/update_password" }      
      let(:passcode) { "wlekrjwelirwj" }

      its(:success) { should == "false" }
    end
  end

end
