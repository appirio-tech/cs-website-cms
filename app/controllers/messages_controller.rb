class MessagesController < ApplicationController
  before_filter :authenticate_user!

  def index
    flash.now[:notice] = 'Message successfully sent.' if params[:sent]
    m = Member.new(:name => current_user.username)
    @all_messages = MessageBox.new(current_user.username, m.inbox, m.from)
    respond_to do |format|
      format.html
      format.json { 
        render :json => @all_messages.to_messages.select { |m| m if m['status'] == 'unread' }
      }
    end         
  end

  def show
    @message = Message.find(params[:id])
    data = {status_from: 'Read'}
    data = {status_to: 'Read'} if current_user.username.eql?(@message.to__r.name)    
    # mark the message as being read
    @message.mark_as_read(data)    
  end

  def create
    h = {:from => current_user.username}.merge!(params[:message])
    render :json => Message.new(h).create
  end

  def reply
    message = Message.find(params[:id])
    # find the to person from the origina message
    to_member = message.to__r.name == current_user.username ? message.from__r.name : message.to__r.name
    h = {:id => params[:id], :from => current_user.username, :to => to_member, 
      :subject => message.subject, :body => params[:body]}
    render :json => Message.new(h).reply
  end
end
