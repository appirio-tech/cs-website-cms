class EventsController < ApplicationController

  def show
  	@event = RestforceUtils.query_salesforce("select Id, Name, 
  		Event_Id__c, Logo__c, Paragraph_1__c, Paragraph_2__c, 
  		Campaign_Source__c, Campaign_Medium__c, Campaign_Name__c 
  		from Signup_Event__c
  		where event_id__c = '#{params[:id]}'").first

  	if @event
	    cookies[:marketing_campaign_source] = @event.campaign_source
	    cookies[:marketing_campaign_medium] = @event.campaign_medium
	    cookies[:marketing_campaign_name] = @event.campaign_name
		else
			redirect_to '/not_found'
		end	    

  end

end
