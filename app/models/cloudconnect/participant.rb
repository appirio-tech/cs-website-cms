class Cloudconnect::Participant < ActiveRecord::Base

  establish_connection "cloudconnect"
  set_table_name "challenge_participant__c"

end