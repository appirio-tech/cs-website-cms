class Docusign

  class DocusignException < Exception
  end

  def self.client
    @client ||= DocusignRest::Client.new
  end

  # gets an envelope's text tabs of the signed document.
  def self.get_envelope_text_tabs(envelope_id)
    response = client.get_envelope_recipients(envelope_id: envelope_id, include_tabs: true)

    # railse an exception when the response has an error
    raise DocusignException.new(response) if response["errorCode"].present?

    response["signers"].first["tabs"]["textTabs"]

  rescue Exception => e
    raise DocusignException.new(e.message)    
  end


  def initialize(user, template)
    @user = user
    @template_id = template
  end

  # gets recipient view url of the docusign template.
  def recipient_view_url(return_url)

    # raise an exception when it fails to create envelope.
    raise DocusignException.new(envelope_response) if envelope_id.nil?

    url = client.get_recipient_view(
      envelope_id: envelope_id,
      name: @user.username,
      email: @user.email,
      return_url: return_url + "?envelope_id=#{envelope_id}"
    )

    # raise an exception when it fails to get recipient view url.
    # It would be better if docu_rest gem returns an error response, 
    # cause we could know the specipic reason why it fails. 
    # But docu_rest gem only resturns url, we can monkey patch it later if we really need.
    raise DocusignException.new("Cannot get view url") if url.nil?

    url

  rescue Exception => e
    raise DocusignException.new(e.message)
  end


  private
  # creates envelop from the template and returns the response.
  def envelope_response
    @envelope_response ||= client.create_envelope_from_template(
      status: 'sent',
      email: {
        subject: "CloudSpokes Member Tax Document for #{@user.username}",
        body: "Please DocuSign your document."
      },
      template_id: @template_id,
      signers: [{
        embedded: true,
        email: @user.email,
        name: @user.username,
        role_name: "RoleOne",
      }]
    )    
  end

  def envelope_id
    @envelope_id ||= envelope_response["envelopeId"]    
  end


  def client
    @client ||= self.class.client
  end

end