module ChallengesHelper
  def search_radio_button(name, value)
    content_tag(:label, class: "inline") do
      radio_button_tag("search[#{name}]", value, search_options[name.to_sym] == value) + " " + 
      content_tag(:span, value.humanize)
    end
  end

  def search_checkbox(name, value)
    content_tag(:label, class: "inline") do
      check_box_tag("search[#{name}][]", value, search_options[name.to_sym].include?(value)) + " " + 
      content_tag(:span, value.humanize)
    end    
  end

  def search_options
    @search_options ||= begin
      default = {state: "open", order: "asc", sort_by: "title", categories: [], prize_money: {}, participants: {}}
      (params[:search] || {}).reverse_merge(default)
    end
  end

  def format_long_challenge_name(name)
    if name && name.length > 45
      "#{name[0...43]}..."
    else
      name
    end
  end

  def participant_submission_date(submission_date_utc)
    timezone = Rails::application.config.time_zone
    timezone = current_user.time_zone if current_user
    "#{submission_date_utc.in_time_zone(timezone).strftime("%-m/%-d/%y %l:%M %p")}" if submission_date_utc
  end  

  def format_challenge_end_date(end_date_utc)
    timezone = Rails::application.config.time_zone
    timezone = current_user.time_zone if current_user
    "#{end_date_utc.in_time_zone(timezone).strftime("%b %d, %Y at %l:%M %p")}" if end_date_utc
  end

  def format_date_time(date_utc)
    timezone = Rails::application.config.time_zone
    timezone = current_user.time_zone if current_user
    "#{date_utc.in_time_zone(timezone).strftime("%b %d, %Y at %H:%M %p")}" if date_utc
  end  

  def format_challenge_due_in(end_date_utc)
    if end_date_utc.past?
      'Completed'
    else
      time_diff_components = Time.diff(Time.now.utc, end_date_utc, '%d %H %N')
      "Due in #{time_diff_components[:diff]}"
    end
  end

  def platform_and_technology_tag_links(challenge)
    tags = []
    challenge.platforms.each do |platform| 
      tags.push link_to(platform, challenges_path(platform: platform))
    end
    challenge.technologies.each do |platform| 
      tags.push link_to(platform, challenges_path(technology: platform))
    end

    tags.join(" | ").html_safe
  end  

  def platform_and_technology_tag_display(challenge)
    tags = []
    challenge.platforms.each do |platform| 
      tags.push platform
    end
    challenge.technologies.each do |technology| 
      tags.push technology
    end

    tags.join(" | ").html_safe
  end    

  def technology_tag_links(challenge)
    tags = []
    challenge.technologies.each do |platform| 
      tags.push link_to(platform, challenges_path(technology: platform))
    end

    tags.join(" | ").html_safe
  end

  def platform_display(challenge)
    tags = []
    challenge.platforms.each do |platform| 
      tags.push platform
    end

    tags.join(", ").html_safe
  end  

  def challenge_type_label(value)
    return 'SWEEP<br>STAKES' if value.eql?('SWEEPSTAKES')
    value
  end

  def challenge_closed_status_label(value)
    return 'Review' if value.eql?('Open for Submissions')
    value
  end

end
