class CloudspokesFeed < ActiveRecord::Base
  attr_accessible :guid, :name, :published_at, :summary, :entry_type, :url

  def self.update_news_from_feed
    update_from_feed('http://blog.cloudspokes.com/feeds/posts/default/-/news?alt=rss','news')
  end

  def self.update_posts_from_feed
    update_from_feed('http://blog.cloudspokes.com/feeds/posts/default/-/CloudSpokes?alt=rss','posts')
  end  

  private

    def self.update_from_feed(url, type)
      feed = Feedzirra::Feed.fetch_and_parse(url)
      feed.sanitize_entries!
      feed.entries.each do |entry|
      	unless exists? :guid => entry.id
      		create!(
      			:name => entry.title,
      			:summary => 'WHY IS THERE NO FEED SUMMARY TEXT? DO WE WANT TO REMOVE THIS?',
      			:url => entry.url,
      			:entry_type => type,
      			:published_at => entry.published,
      			:guid => entry.id
      		)
      	end  
      end
    end

end
