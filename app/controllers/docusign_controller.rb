class DocusignController < ApplicationController

  # shows embedded docusign page.
  def embedded_signing
    docusign = Docusign.new(current_user, params[:template])
    @url = docusign.recipient_view_url(docusign_response_url)

  rescue Docusign::DocusignException => e
    Rails.logger.error "   [Docusign Error] Error occurs while fetcing docusign document : #{e.message}"
    redirect_to payment_info_path, alert: "Sorry, error occurs while fetching Docusing document"
  end

  # return url after signing the embedded docusign page.
  def docusign_response
    utility = DocusignRest::Utility.new

    if params[:event] == "signing_complete"
      begin
        # updates member from the information of the signed document.
        tabs = Docusign.get_envelope_text_tabs(params[:envelope_id])
        Member.http_put("members/#{current_user.username}", extract_member_info_from_tabs(tabs))
        flash[:notice] = "Thanks! Successfully signed"
        
      rescue Docusign::DocusignException => e
        # TODO : how to handle this case?
        Rails.logger.error "   [Docusign Error] Error occurs while handling docugign response : #{e.message}"
        flash[:alert] = "Sorry, error occurs while updating your Docusign response"
      end
    else
      flash[:alert] = "You chose not to sign the document. Try it later!"
    end

  ensure

    # redirect the parent page to the payment_info_path using javascript.
    # see https://github.com/j2fly/docusign_rest
    render :text => utility.breakout_path(payment_info_path), content_type: :html
  end


  private
  def extract_member_info_from_tabs(tabs)
    result = {
      paperwork_received: "Paper Work Received",
      paperwork_year: Time.now.year,
      country: 'United States'
    }

    # each tab has tabLabel and value fields. We can extract some information we need.
    tabs.each do |tab|
      label = tab["tabLabel"]
      value = tab["value"]

      if( label == "Name" ) 
        result[:first_name], result[:last_name] = value.split(" ").map(&:strip)
      elsif( label == "Address" ) 
        result[:address_line1] = value.strip
      elsif( %w(City State Zip Country).include?(label) )
        result[label.downcase.to_sym] = value.strip
      end
    end

    result
  end
end
