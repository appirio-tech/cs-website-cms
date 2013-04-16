require 'spec_helper'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into :webmock # or :fakeweb
  c.default_cassette_options = { :record => :new_episodes }
end

# describe 'VCR Test' do
#   it 'works according to the readme' do
#     VCR.use_cassette('synopsis') do
#       response = Net::HTTP.get_response(URI('http://www.iana.org/domains/example/'))
#       assert_match /Example Domains/, response.body
#     end
#   end
# end
