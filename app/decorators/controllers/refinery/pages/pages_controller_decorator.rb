Refinery::PagesController.class_eval do
  skip_before_filter :find_page, :only => [:home]
  def home
    @stats = CsPlatform.stats
    @news_feed_items = CloudspokesFeed.where(:entry_type => 'news').order('created_at desc').limit(3)
    @post_feed_items = CloudspokesFeed.where(:entry_type => 'posts').order('created_at desc').limit(3)     
  end
end