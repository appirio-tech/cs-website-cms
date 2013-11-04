class AdminController < ApplicationController
	require 'feedzirra'

	http_basic_authenticate_with :name => ENV['WEB_ADMIN_USERNAME'], :password => ENV['WEB_ADMIN_PASSWORD']

	def blog_fodder
		@challenge = Challenge.find params[:challenge_id]
	end

	def loadrss
		puts "Update news feed from RSS"
		CloudspokesFeed.update_news_from_feed
		puts "Update posts feed from RSS"
		CloudspokesFeed.update_posts_from_feed		
		redirect_to admin_path, :notice => "News & Posts RSS feeds successfully updated."
	end	

	def cms
		REDIS.set params['key'], params['content']
		redirect_to admin_path, :notice => "You crappy content has been updated."
	end

	def api_spin
		REDIS.hset 'cs:mashathon', params[:membername], params[:apis].split(',').to_json
		redirect_to admin_path, :notice => "APIs recorded for #{params[:membername]}"
	end	

end
