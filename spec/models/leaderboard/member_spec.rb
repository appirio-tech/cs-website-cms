describe Leaderboard::Member do
  let(:username) { "abhar" }
  let(:attributes) {
    {
      name: username,
      picture: "http://cloudspokes.s3.amazonaws.com/Cloud_th_100.jpg",
    }
  }
  let(:member) { Leaderboard::Member.new(attributes) }
  let(:key) { Leaderboard::Member.key(username) }

  before(:all) do
    Leaderboard.clear_redis
  end

  describe ".find_by_name" do
    before do
      REDIS.set key, attributes.to_json
    end

    it "returns member of username" do
      member = Leaderboard::Member.find_by_name(username)

      member.should be_instance_of(Leaderboard::Member)
      member.name.should == username
    end

    it "returns nil if username does not exist" do
      member = Leaderboard::Member.find_by_name("")

      member.should == nil
    end
  end

  describe "#exist?" do
    before do
      REDIS.set key, attributes.to_json
    end

    it "is true if member exists in redis" do
      member = Leaderboard::Member.new(name: username)
      member.should be_exist
    end

    it "is false if member does not exist" do
      member = Leaderboard::Member.new(name: "nobody")
      member.should_not be_exist
    end
  end

  describe "#save" do
    before(:each) do
      member.save
    end

    it "saves user to redis" do
      REDIS.get(key).should == member.to_json
    end
  end

  describe "#delete" do
    before(:each) do
      Leaderboard::Member.new(attributes).save
      member.delete
    end

    it "deletes user from redis" do
      REDIS.get(key).should == nil
    end
  end
end
