require "csv"

describe Leaderboard do

  def load_data
    filename = Rails.root.join("spec/fixtures/scores.csv")
    data = CSV.read(filename)
    data.map do |row|
      next if row.first == "challenge"

      attrs = {
        challenge_id: row[0],
        username: row[1],
        prize: row[2],
        categories: row[3],
        date: row[4],
        community: (row[5].present? ? row[5] : nil)
      }
      Leaderboard::Score.new(attrs).save

      Leaderboard::Member.new(name: row[1]).save unless Leaderboard::Member.find_by_name(row[1])
    end
  end

  before(:each) do
    Leaderboard.clear_redis
    load_data
  end

  # TODO : it does not seem to be right way to test.
  it "#leaders" do
    leaders = Leaderboard.leaders
    leaders.map(&:name).should == ["avidev9", "akkishore", "Kenji776", "romin", "kzer95", "peakpado", "mbleigh", "talesforce", "soe", "logontokartik"]
    leaders.map(&:total_prizes).should == [18650.0, 16500.0, 16100.0, 15650.0, 13400.0, 9950.0, 9350.0, 9300.0, 8350.0, 7450.0]
    leaders.map(&:total_wins).should == [25, 19, 19, 23, 10, 18, 9, 15, 7, 13]
    leaders.map(&:rank).should == [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

    # page
    leaders = Leaderboard.leaders(page: 2)
    leaders.map(&:name).should == ["wcheung", "antenna", "sgurumurthy", "helperyadav", "mural", "dubeynikhileshs", "swalehji", "rubixtious", "jazzyrocksr", "elukaweski"]

    # community
    leaders = Leaderboard.leaders(community: "cloudfoundry")
    leaders.map(&:name).should == ["Kenji776", "peakpado", "wcheung", "romin", "akkishore", "mbleigh", "sgurumurthy", "vzmind", "raygao", "ckeene"]
    leaders = Leaderboard.leaders(category: "cloudfoundry")
    leaders.map(&:name).should == []

    # year, month
    leaders = Leaderboard.leaders(category: "ruby")
    leaders.map(&:name).should == ["peakpado", "mbleigh", "soe", "raygao", "jaipandya", "darthdeus", "avidev9", "gregr", "rubysolo", "fractastical"]
    leaders = Leaderboard.leaders(category: "ruby", year: "2012")
    leaders.map(&:name).should == ["peakpado", "soe", "mbleigh", "jaipandya", "darthdeus", "avidev9", "rubysolo"]
    leaders = Leaderboard.leaders(category: "ruby", year: "2012", month: "1")
    leaders.map(&:name).should == ["peakpado", "darthdeus"]
  end

end
