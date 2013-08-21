module AccountsHelper
  def preferred_payment_options
    [["Please select ...",nil],["Check","Check"],["Paypal E-cheques","Paypal E-cheques"],["Paypal","Paypal"],["Wire","Wire"]]
  end
  def work_options
    [["Please select ...",nil],["Contractor","Contractor"],["Employed","Employed"],["Unemployed","Unemployed"],["Prefer Not To Answer","Prefer Not To Answer"]]
  end

  def shirt_size_options
    [["Please select ...",nil],["M-small","M-small"],["M-medium","M-medium"],["M-large","M-large"],["M-x-large","M-x-large"],["W-small","W-small"],["W-medium","W-medium"],["W-large","W-large"],["W-x-large","W-x-large"]]
  end

  def age_range_options
    [["Please select ...",nil],["14-20","14-20"],["21-30","21-30"],["31-40","31-40"],["41-60","41-60"],["60+","60+"],["Prefer not answer","Prefer not answer"]]
  end

  def gender_options
    [["Please select ...",nil],["Male","Male"],["Female","Female"]]
  end

  # Generates the preferences check box tags, given a preference object field
  def preference_check_box_tags(field)
    Preference.notification_options.map do |value|
      check_box_tag("preferences[#{field.event}][]", value, !field.notification_method.nil? && field.notification_method.include?(value))
    end.join('</td><td class=\'check-boxes\'>').html_safe
  end

end
