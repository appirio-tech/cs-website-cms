class MessagesController < ApplicationController

  def index
    @messages = Member.new(:name => current_user.username).inbox
    #render :json => @messages.first
    @message_box = MessageBox.new(current_user.username, :inbox, @messages)
  end

  def show
  end

  def create
  end

  def reply
  end
end
