#class Submission < Hashie::Mash
  #extend ActiveModel::Naming
class Submission < ApiModel

  def self.api_endpoint
    "#{ENV['CS_API_URL']}/challenges"
  end

  LANGUAGES = %w{Node Java JavaScript Ruby Python Apex Other}
  PAAS = ["Heroku", "Salesforce.com", "CloudFoundry", "Google App Engine", "Other"]
  APIS = ["DocuSign REST API", "FullContact", "Google Chart Tools", "Twilio", "Other"]
  TECHNOLOGIES = ["redis", "mongodb", "rabbitmq", "Other"]

  attr_accessor :id, :apis, :paas, :languages, :technologies, :submission_overview, :deliverables,
                :challenge_id, :username, :participant, :next_deliverable_id

  class << self
    def find(challenge_id, username='jeffdonthemic')
      puts "find"
      puts challenge_id

      challenge_id = challenge_id
      username = username

      participant = Participant.find_by_member(challenge_id, username)
      deliverables = participant.submission_deliverables

      attrs = {
        :apis => participant.apis||[], 
        :paas => participant.paas||[], 
        :languages => participant.languages||[], 
        :technologies => participant.technologies||[],
        :submission_overview => participant.submission_overview,
        :deliverables => deliverables,


        :next_deliverable_id => deliverables.length || 1
      }

      submission = new attrs.merge(username: username, challenge_id: challenge_id, participant: participant)

      submission
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
    puts "save"
  end

  def update(attrs)
    puts "update"

    attrs.each do |k, v|
      if v.kind_of?(Array) and v[0] == ""
        attrs[k].shift
      end
    end

    fields = {
      submission_overview: attrs["submission_overview"],
      apis: attrs["apis"].join(";"),
      paas: attrs["paas"].join(";"),
      languages: attrs["languages"].join(";"),
      technologies: attrs["technologies"].join(";")
    }

    self.class.naked_put "participants/#{username}/#{challenge_id}", {'fields' => fields}
  end

  def destroy
    puts "destroy"
  end


  def create_deliverable(attrs)

    deliverable = SubmissionDeliverable.new
    deliverable.type = attrs[:type]
    deliverable.comments = attrs[:comments]
    deliverable.url = attrs[:url]
    deliverable.hosting_platform = attrs[:hosting_platform]
    deliverable.language = attrs[:language]
    deliverable.source = attrs[:source]

    # assign a uniq deliverable id
    # deliverable.id = next_deliverable_id
    # self.next_deliverable_id += 1

    # create the new deliverable record
    deliverable = self.class.naked_post "participants/#{username}/#{challenge_id}/deliverable", {data: deliverable}

    self.deliverables << deliverable

    puts deliverables

    deliverable
  end

  def find_deliverable(deliverable_id)
    deliverables.detect {|d| d.id == deliverable_id}
  end

  def delete_deliverable(deliverable_id)
    puts "delete_deliverable"

    # needs delete endpoint
  end

  def destroy_deliverable(deliverable_id)
    deliverable = find_deliverable(deliverable_id)
    deliverable = deliverable.raw_data

    # destroy the deliverable file if it is stored in S3
    if deliverable.source == "storage"
      file = storage.files.get deliverable.url
      puts file
      file.destroy if file
    end

    # after destroying the deliverable file, delete the deliverable entry too
    delete_deliverable(deliverable_id)

    deliverable
  end

  def upload_file(file)
    puts "upload_file"
    file = storage.files.create(
      :key    => storage_path(File.basename(file.original_filename)),
      :body   => file.read,
      :public => true
    )

    create_deliverable type: "Code", hosting_platform: "Other", language: "Other", url: file.key, source: "storage"
  end

  private
    
    def storage
      self.class.storage
    end
    
    def storage_path(name)
      "challenges/#{challenge_id}/#{username}/#{name}"
    end
end
