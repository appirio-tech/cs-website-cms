class Preference

  # Each attribute is an array of either ['email'], ['popup'], or ['email', 'popup']
  # We use an array to give us flexibility when we need to add other notification types
  # (e.g. 'sms' or 'private_message')
  attr_accessor :id, :do_not_notify, :event, :notification_method, :type

  def initialize(pref)
    @id = pref.id
    @event = pref.event 
    @do_not_notify = pref.do_not_notify
    @notification_method = pref.notification_method.downcase.split(';') unless @do_not_notify

    if pref.event.include?('|')
      @type = pref.event[0..pref.event.index('|')-1].downcase.to_sym
    else
      @type = :general
    end
  end

  # The list of possible notification options. Can be changed so that the source
  # is from an API call or database storage (or even a configuration file)
  # This is used by the check_box_tag helper methods
  def self.notification_options
    ['email', 'site']
  end  

end