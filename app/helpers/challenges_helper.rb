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
end
