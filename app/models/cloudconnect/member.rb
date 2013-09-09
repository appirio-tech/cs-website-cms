class Cloudconnect::Member < ActiveRecord::Base

  establish_connection "cloudconnect"
  set_table_name "member__c"

  # rename all columns and remove '__c'
  # Cloudconnect::Member.column_names.each do |att|
  #   new_att = (att.downcase.gsub(/__c$/,'') rescue att) || att
  #   alias_attribute new_att, att
  # end

end