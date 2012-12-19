class Deliverable < Hashie::Mash
  extend ActiveModel::Naming

  TYPES = ["Code", "Demo URL", "Documentation", "Github Pull Request", "Image / Graphic", "Screencast / Video", "Unmanaged Package"]
  PAAS = ["Heroku", "Salesforce.com", "CloudFoundry", "Google App Engine", "Other"]

  class << self
    def create(attrs)
      new attrs
    end
  end

  def update(attrs)
    attrs.each {|k,v| send("#{k}=", v)}
  end

end