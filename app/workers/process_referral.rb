class ProcessReferral
  
  @queue = :process_referral
  def self.perform(referral_id_or_username, converted_member_name)
    
    puts "======== the referral ran!! #{referral_id_or_username}"
  
  end
  
end