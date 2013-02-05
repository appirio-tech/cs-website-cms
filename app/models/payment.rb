class Payment < ApiModel
  attr_accessor :id, :name, :money, :place, :reason, :status, :type, 
    :reference_number, :payment_sent, :challenge

  def self.api_endpoint
    "#{ENV['CS_API_URL']}/members"
  end

  def initialize(params={})
    params['challenge'] = params.delete('challenge__r') if params['challenge__r']

    super(params)
  end

  def paid?
    status == "Paid"
  end
end