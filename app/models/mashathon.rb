class Mashathon

  class << self
    def find_by_user(user)
      self.new(user.username, REDIS.hget(key, user.username))  
    end

    def all
      REDIS.hgetall(key).map do |name, apis| 
        self.new(name, apis)
      end
    end

    def key
      "cs:mashathon"
    end
  end



  APIS = [      
    "AWS",
    "Google",
    "Yelp",
    "Facebook",
    "Smartsheet",
    "Docusign",
    "Twitter",
    "CS / TC",
    "Pick One",
    "FinancialForce"
  ]

  attr_reader :username, :apis
  def initialize(username, apis = [])
    @username = username

    @apis = apis.is_a?(Array) ? apis : (JSON.parse(apis.to_s) rescue [])
  end

  def pick_api
    return if @apis.count >= 3
    api = (APIS - @apis).sample
    @apis.push(api)
    save

    api
  end

  def save
    REDIS.hset self.class.key, @username, @apis.to_json
  end

  def clear
    @apis = []
    save
  end

end