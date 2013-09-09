class Cloudconnect::Challenge < ActiveRecord::Base

  establish_connection "cloudconnect"
  set_table_name "challenge__c"

end