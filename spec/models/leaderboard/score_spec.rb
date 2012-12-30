describe Leaderboard::Score do
  let(:username) { "Ramaki" }
  let(:attributes) {
    {
      challenge_id: "1534",
      username: username,
      place: 1,
      prize: 50.0,
      categories: "mobile,ios",
      date: "2012. 6. 8.",
      community: "java"
    }
  }

  let(:score) { Leaderboard::Score.new attributes }

  before do
    Leaderboard.clear_redis

    member_attrs = {name: username, picture: "http://cloudspokes.s3.amazonaws.com/Cloud_th_100.jpg"}
    Leaderboard::Member.new(member_attrs).save 
  end

  describe "#initialize" do
    subject { score }

    its(:challenge_id) { should == "1534" }
    its(:username) { should == username}
    its(:place) { should == 1}
    its(:prize) { should == 50.0}
    its(:categories) { should == ["mobile", "ios"]}
    its(:date) { should == Time.parse("2012-06-08")}
    its(:community) { should == "java"}

    it "sets prize as a float format" do
      score = Leaderboard::Score.new attributes
      score.prize.should == 50.0
    end
    it "sets categoris as an array format" do
      score = Leaderboard::Score.new attributes
      score.categories.should == ["mobile", "ios"]

      score = Leaderboard::Score.new attributes.update(categories: "mobile, ios")
      score.categories.should == ["mobile", "ios"]

      score = Leaderboard::Score.new attributes.update(categories: "")
      score.categories.should == []
    end
    it "sets date as a date format" do
      score = Leaderboard::Score.new attributes
      score.date.should == Time.parse("2012-06-08")
    end

    context "when date is not present from attributes" do
      it "sets date as nil" do
        score = Leaderboard::Score.new attributes.merge(date: "")
        score.date.should == nil
      end
    end
  end

  describe "#categories=" do
    context "when value is string" do
      it "sets categories as splited string" do
        score.categories = "mobile,ios"
        score.categories.should == ["mobile", "ios"]

        score.categories = "mobile, ios"
        score.categories.should == ["mobile", "ios"]
      end
    end
    context "when value is empty string" do
      it "sets categories []" do
        score.categories = ""
        score.categories.should == []        
      end
    end
    context "when value is array" do
      it "sets categories input value" do
        score.categories = ["mobile", "ios"]
        score.categories.should == ["mobile", "ios"]
      end
    end
  end

  describe "#community" do
    it "default is all" do
      score.community = nil
      score.community.should == "all"
    end
  end


  describe "#save" do
    let(:key) { "cs:leaderboard:score:Ramaki:1534" }

    it "saves score to redis" do
      score.save
      REDIS.get(key).should == score.to_json
    end

    it "returns true" do
      score.save.should == true
    end

    it "updates leaderboards" do
      score.save

      # updates prizes
      REDIS.zscore("cs:leaderboard:java:all:all:all:prizes", username).to_i.should == 50
      REDIS.zscore("cs:leaderboard:java:all:2012:all:prizes", username).to_i.should == 50
      REDIS.zscore("cs:leaderboard:java:all:2012:6:prizes", username).to_i.should == 50
      # udpates ios category
      REDIS.zscore("cs:leaderboard:java:ios:all:all:prizes", username).to_i.should == 50
      REDIS.zscore("cs:leaderboard:java:ios:2012:all:prizes", username).to_i.should == 50
      REDIS.zscore("cs:leaderboard:java:ios:2012:6:prizes", username).to_i.should == 50
      # updates mobile category
      REDIS.zscore("cs:leaderboard:java:mobile:all:all:prizes", username).to_i.should == 50
      REDIS.zscore("cs:leaderboard:java:mobile:2012:all:prizes", username).to_i.should == 50
      REDIS.zscore("cs:leaderboard:java:mobile:2012:6:prizes", username).to_i.should == 50
    
      # updates wins
      REDIS.zscore("cs:leaderboard:java:all:all:all:wins", username).to_i.should == 1
      REDIS.zscore("cs:leaderboard:java:all:2012:all:wins", username).to_i.should == 1
      REDIS.zscore("cs:leaderboard:java:all:2012:6:wins", username).to_i.should == 1
      REDIS.zscore("cs:leaderboard:java:ios:all:all:wins", username).to_i.should == 1
      REDIS.zscore("cs:leaderboard:java:ios:2012:all:wins", username).to_i.should == 1
      REDIS.zscore("cs:leaderboard:java:ios:2012:6:wins", username).to_i.should == 1
      REDIS.zscore("cs:leaderboard:java:mobile:all:all:wins", username).to_i.should == 1
      REDIS.zscore("cs:leaderboard:java:mobile:2012:all:wins", username).to_i.should == 1
      REDIS.zscore("cs:leaderboard:java:mobile:2012:6:wins", username).to_i.should == 1
    
      # does not add to all community
      REDIS.zscore("cs:leaderboard:all:all:all:all:prizes", username).to_i.should == 0
      REDIS.zscore("cs:leaderboard:all:all:all:all:wins", username).to_i.should == 0
    end

    context "when score exists" do
      before(:each) do
        REDIS.set(key, score.to_json)
      end
      it "resturns false" do
        score.save.should == false
      end

      it "does not save to reids" do
        REDIS.should_not_receive(:set)
        score.save
      end
    end
  end

end
