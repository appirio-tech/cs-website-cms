class CloudspokesFeed < ActiveRecord::Base
  attr_accessible :guid, :name, :published_at, :summary, :entry_type, :url

  def self.update_press_from_feed
    update_from_feed('http://feeds.feedburner.com/TheCloudSpokesBlog','press')
  end

  def self.update_posts_from_feed
    update_from_feed('http://feeds.feedburner.com/TheCloudSpokesBlog','posts')
  end  

  def self.update_from_feed(url, type)
    feed = Feedzirra::Feed.fetch_and_parse(url)
    feed.sanitize_entries!
    feed.entries.each do |entry|
    	unless exists? :guid => entry.id
    		create!(
    			:name => entry.title,
    			:summary => 'really cool summary will eventually be here',
    			:url => entry.url,
    			:entry_type => type,
    			:published_at => entry.published,
    			:guid => entry.id
    		)
    	end  
    end
  end

end
