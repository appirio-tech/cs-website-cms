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

  def format_close_date_time(end_time)
    if end_time.past?
        display = "Completed"
    else
      secs = end_time - Time.now
      display = "due in "
      display += pluralize((secs/86400).floor, 'day')
      secs = secs%86400
      display += " " + pluralize((secs/3600).floor, 'hour') + " " + pluralize(((secs%3600)/60).round, 'minute')
    end
  end

end
