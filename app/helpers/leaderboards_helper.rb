module LeaderboardsHelper
  def lb_community_names
    %w(all java cloudfoundry)
  end
  def lb_category_names
    %w(Heroku Salesforce.com Google Box Mobile Node.JS Ruby JavaScript Java Other all)
  end

  def category_nav_tag(cat_name)
    cat_name = cat_name.downcase
    class_names = [cat_name.split(".").first]
    class_names.push("active") if (params[:category] || "all") == cat_name
    link_to cat_name, leaderboards_path(category: cat_name, community: params[:community]), class: class_names.join(" ")
  end

  def member_rank_class_name(member)
    case member.rank
    when 1
      "gold"
    when 2
      "silver"
    when 3
      "bronze"
    else
      ""
    end
  end

end
