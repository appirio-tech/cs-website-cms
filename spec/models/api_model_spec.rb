class TestApiModel < ApiModel
  attr_accessor :id, :name, :desc

  has_many :members

  def self.api_endpoint
    'http://cs-api-sandbox.herokuapp.com/v1/challenges'
  end
end

describe ApiModel do
  let(:attrs) { {name: "test", desc: "description"} }
  let(:model) { TestApiModel.new attrs}
  let(:headers) { 
    { 
      'Content-Type' => 'application/json', 
      "Authorization" => "Token token=#{ApiModel::ACCESS_TOKEN}" 
    }
  }

  describe "#new_record?" do
    it "is ture if id is not assigned" do
      model.should be_new_record
    end
    it "is false if id is assigned" do
      model.id = "123"
      model.should_not be_new_record
    end
  end

  describe "#save" do
    before do
      model.stub(:update)
      model.stub(:create)
    end

    context "when model is new record" do
      before { model.stub(:new_record?).and_return(true) }
      it "creates a new model" do
        model.should_receive(:create)
        model.save
      end
    end
    context "when model is not a nuew record" do
      before { model.stub(:new_record?).and_return(false) }
      it "updates a model" do
        model.should_receive(:update)
        model.save
      end
    end
  end

  describe "#update_attributes" do
    let(:update_attrs) { {name: "update"} }
    before do
      model.stub(:save)
    end
    it "updates attributes" do
      model.update_attributes(update_attrs)
      model.name.should == "update"
    end

    it "calls save" do
      model.should_receive(:save)
      model.update_attributes(update_attrs)
    end
  end

  describe "#save_data" do
    it "excludes relation attributes" do
      data = model.send(:save_data)
      data.keys.should_not include(:members)
    end

    it "excludes attributes whose value is nil" do
      model.desc = nil
      data = model.send(:save_data)
      data.keys.should_not include(:desc)      
    end
    it "excludes id attribute" do
      model.id = "123"
      data = model.send(:save_data)
      data.keys.should_not include(:id)            
    end
  end

  describe "#create" do
    it "sends post request with access_token" do
      stub_request(:post, "http://cs-api-sandbox.herokuapp.com/v1/challenges")
      .with(headers: headers, body: attrs.to_json).to_return(:body => "{}")
      model.send(:create)
    end

    context "when model has create_endpint" do
      before do
        model.class.class_eval %q{
          def create_endpoint
            "help_me"
          end
        }
      end
      it "sends post request to create_endpoint" do
        stub_request(:post, "http://cs-api-sandbox.herokuapp.com/v1/challenges/help_me").to_return(:body => "{}")
        model.send(:create)
      end
    end

  end

  describe "#update" do
    before do
      model.id = "123"
    end
    it "sends put request with access_token" do
      stub_request(:put, "http://cs-api-sandbox.herokuapp.com/v1/challenges/123")
      .with(headers: headers, body: attrs.to_json).to_return(:body => "{}")
      model.send(:update)
    end

    context "when model has update_endpint" do
      before do
        model.class.class_eval %q{
          def update_endpoint
            "help_me"
          end
        }
      end
      it "sends put request to update_endpoint" do
        stub_request(:put, "http://cs-api-sandbox.herokuapp.com/v1/challenges/help_me").to_return(:body => "{}")
        model.send(:update)
      end
    end
  end

  describe ".request" do
    let(:data) { {by: "superuser"} }
    let(:response) { {response: {success: "true"}} }
    before do
      stub_request(:post, "http://cs-api-sandbox.herokuapp.com/v1/challenges/3/close")
      .with(headers: headers, body: data.to_json).to_return(:body => response.to_json)      
    end
  
    context "when method is post" do
      it "sends post request with body to endpoint" do
        TestApiModel.request(:post, "3/close", data)
      end      
    end

    context "when entities is array" do
      it "sends post request to endpoint" do
        TestApiModel.request(:post, [3, "close"], data)
      end      
    end

    context "when data is string" do
      it "sends data without converting" do
        TestApiModel.request(:post, "3/close", data.to_json)
      end            
    end

    it "response is parsed" do
      resp = TestApiModel.request(:post, "3/close", data)
      resp.success.should == "true"
    end
  end
  
end