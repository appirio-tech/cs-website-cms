class Submission < Hashie::Mash
  extend ActiveModel::Naming

  LANGUAGES = %w{Node Java JavaScript Ruby Python Apex Other}
  PLATFORMS = ["Heroku", "Salesforce.com", "CloudFoundry", "Google App Engine", "Other"]
  APIS = ["DocuSign REST API", "FullContact", "Google Chart Tools", "Twilio", "Other"]
  TECHNOLOGIES = ["redis", "mongodb", "rabbitmq", "Other"]

  class << self
    def find(challenge_id, username='jeffdonthemic')
      key = "#{challenge_id}:#{username}"
      json = REDIS.hget(redis_key, key) || "{}"
      attrs = JSON.parse(json).symbolize_keys
      attrs[:next_deliverable_id] ||= 1
      deliverables = attrs.delete(:deliverables) || []
      deliverables = deliverables.map {|d| Deliverable.new(d)}

      submission = new attrs.merge(username: username, challenge_id: challenge_id)
      submission.deliverables ||= []
      submission.deliverables.concat deliverables

      puts submission.to_json

      submission
    end

    def redis_key
      "cs:submissions"
    end

    def storage
      @storage ||= begin
        fog = Fog::Storage.new(
          :provider                 => 'AWS',
          :aws_secret_access_key    => ENV['AWS_SECRET'],
          :aws_access_key_id        => ENV['AWS_KEY']
        )
        fog.directories.get(ENV['AWS_BUCKET'])
      end
    end
  end

  def save
    REDIS.hset(redis_key, key, self.to_json)
  end

  def update(attrs)
    attrs.each {|k,v| send("#{k}=", v)}
    save
  end

  def destroy
    REDIS.hdel(redis_key, key)
  end


  def create_deliverable(attrs)
    # assign a uniq deliverable id
    attrs[:id] = next_deliverable_id
    self.next_deliverable_id += 1

    deliverable = Deliverable.create(attrs)
    self.deliverables << deliverable
    save

    deliverable
  end

  def find_deliverable(deliverable_id)
    deliverables.detect {|d| d.id == deliverable_id.to_i}
  end

  def destroy_deliverable(deliverable_id)
    deliverable = find_deliverable(deliverable_id.to_i)
    if deliverable.source == "storage"
      file = storage.files.get deliverable.url
      file.destroy if file
    end
    deliverables.delete(deliverable)
    save

    deliverable
  end

  def upload_file(file)
    puts "upload_file"
    file = storage.files.create(
      :key    => storage_path(File.basename(file.original_filename)),
      :body   => file.read,
      :public => true
    )

    puts file.key

    create_deliverable type: "Unmanaged Package", url: file.key, source: "storage"
  end

  private

    def redis_key
      self.class.redis_key
    end

    def key
      @key ||= "#{challenge_id}:#{username}"
    end
    
    def storage
      self.class.storage
    end
    
    def storage_path(name)
      "challenges/#{challenge_id}/#{username}/#{name}"
    end
end
