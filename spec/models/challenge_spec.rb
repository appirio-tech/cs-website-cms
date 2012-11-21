require 'spec_helper'

describe Challenge do
  context 'find by challenge number' do
    use_vcr_cassette
    let(:challenge) { Challenge.find(2) }

    it 'retrieves the correct id' do
      challenge.id.should == 'a0GZ0000005VQogMAG'
    end

    it 'retrieves the correct total prize money' do
      challenge.total_prize_money.should == 150
    end

    it 'retrieves the correct usage details' do
      challenge.usage_details.should == 'Her&#39;s how you use it.'
    end

    it 'retrieves the correct challenge id' do
      challenge.challenge_id.should == 2.to_s
    end

    it 'retrieves the correct challenge type' do
      challenge.challenge_type.should == 'Code'
    end

    it 'retrieves the correct start and end dates' do
      challenge.start_date.should == Date.parse('2012-11-21T14:22:00.000+0000')
      challenge.end_date.should == Date.parse('2013-01-31T14:22:00.000+0000')
    end

    it 'retrieves the correct open status' do
      challenge.open?.should be_true
    end

    it 'retrieves the correct requirements' do
      challenge.requirements.should == 'Cool challenge requirements.'
    end

    it 'retrieves the correct release to open source status' do
      challenge.release_to_open_source?.should be_false
    end

    it 'retrieves the correct post registration info' do
      challenge.post_reg_info.should == 'This is what you see after registering.'
    end

    it 'retrieves the correct participant count' do
      challenge.participants.count.should == 3
    end      

    it 'retrieves the correct participants' do
      challenge.participants.map { |p| p.member.name }.should == ['aquacdr', 'jeffdonthemic', 'salpartovi']
    end      

    it 'retrieves the correct prize type' do
      challenge.prize_type.should == 'Currency'
    end      

    it 'retrieves the correct discussion board status' do
      challenge.discussion_board.should == 'Show'
    end      

    it 'retrieves the correct number of registered members' do
      challenge.registered_members.should == 2
    end      

    it 'retrieves the correct additional info' do
      challenge.additional_info.should == 'Some additional info'
    end      

    it 'retrieves the correct name' do
      challenge.name.should == 'Test Challenge 1'
    end      

    it 'retrieves the correct top prize' do
      challenge.top_prize.should == '$100'
    end      

    it 'retrieves the correct submission details' do
      challenge.submission_details.should == 'Here&#39;s how to submit!'
    end

    it 'retrieves the correct description' do
      challenge.description.should == 'My cool challenge'
    end

    it 'retrieves the correct winner announced date' do
      challenge.winner_announced.should == Date.parse('2013-02-01')
    end

    it 'retrieves the correct status' do
      challenge.status.should == 'Created'
    end

    it 'retrieves the correct number of comments' do
      # this seems to be an inconsistency in the API that isn't currently handled
      # http://cs-api-sandbox.herokuapp.com/v1/challenges/2/comments
      # the output is a bit messed up; the comment by tnjitsu is nested within the
      # comment by aquacdr -- as of the moment, the models don't support nested comments
      # natively -- we have to write a parser for this to expose the nesting
      # TODO: make this test pass
      challenge.comments.count.should equal(2), 'the challenge model does not yet support nested comments!'
    end

    it 'retrieves the correct commenters' do
      # see above
      # TODO: make this test pass
      challenge.comments.map { |c| c.member.name }.should equal(['aquacdr', 'tnjitsu']), 'the challenge model does not yet support nested comments!'
    end      
  end
end