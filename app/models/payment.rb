class Payment < ApiModel
  attr_accessor :id, :name, :money, :place, :reason, :status, :type, 
    :reference_number, :payment_sent, :challenge

  def self.api_endpoint
    "members"
  end

  def self.has_many_api_endpoint
    api_endpoint
  end    

  def initialize(params={})
    params['challenge'] = params.delete('challenge__r') if params['challenge__r']

    super(params)
  end

  def paid?
    status == "Paid"
  end
end