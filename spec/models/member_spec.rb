require 'spec_helper'

describe Member do

  context 'find by member name' do
    use_vcr_cassette
    let(:member) { Member.find('jeffdonthemic') }

    it 'retrieves the correct id' do
      member.id.should == 'a0IZ0000000FyJUMA0'
    end

    it 'retrieves the correct name' do
      member.name.should == 'jeffdonthemic'
    end

    it 'retrieves the correct profile picture' do
      member.profile_pic.should == 'http://cloudspokes.s3.amazonaws.com/Cloud_th_100.jpg'
    end

    it 'retrieves the correct number of challenges entered' do
      member.challenges_entered.should == 0
    end

    it 'retrieves the correct number of total points' do
      member.total_points.should == 0
    end

    it 'retrieves the correct number of valid submissions' do
      member.valid_submissions.should == 0
    end

    it 'retrieves the correct number of 1st/2nd/3rd place' do
      member.total_1st_place.should == 0
      member.total_2nd_place.should == 0
      # NOTE: is this a mispelling? The API produces it like this
      member.total_3st_place.should == 0
    end

    it 'retrieves the correct Time Zone' do
      member.time_zone.should == '(GMT-07:00) Pacific Daylight Time (America/Los_Angeles)'
    end

    it 'retrieves the correct number of total public money' do
      member.total_public_money.should == 0.0
    end

    it 'retrieves the correct number of total wins' do
      member.total_points.should == 0
    end

    it 'retrieves the correct number of challenges for this member' do
      member.challenges.count.should == 1
    end

    it 'retrieves the correct recommendations' do
      pending 'the api used to have recommendation records, now none of the members have recommendations :('
    end
  end

  context 'find all members' do
    use_vcr_cassette
    let(:all_members) { Member.all }

    it 'retrieves the correct member count' do
      all_members.count.should == 9
    end

    it 'retrieves the correct members' do
      all_members.map { |m| m.name }.should == ["jeffdonthemic", "salpartovi", "mess", "apextestmember", "tnjitsu", "romin", "aquacdr", "cmc", "tehnrd"]
    end
  end

end
