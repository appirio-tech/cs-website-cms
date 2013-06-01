class User < ActiveRecord::Base
  has_and_belongs_to_many :roles, :join_table => :roles_users
  has_many :plugins, :class_name => "UserPlugin", :order => "position ASC", :dependent => :destroy

  has_many :authentications

  devise :database_authenticatable, :registerable, :timeoutable,
         :token_authenticatable, :confirmable, :lockable,
         :lockable, :recoverable
         # :trackable,  

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :username, :time_zone

  validates :username, :presence => true

  def account
    @acount ||= Account.new(self)
  end

  def challenge_admin?(challenge) 
    challenge_sponsor?(challenge) || appirio?
  end  

  def challenge_sponsor?(challenge)
    if challenge.account
      accountid == challenge.account
    else
      false
    end    
  end  

  def appirio?
    email.include?('@appirio.com')
  end

  def use_captcha?(challenge, participant)
    if challenge_admin?(challenge) || (participant.member && participant.member.valid_submissions > 0)
      false
    else
      true
    end
  end

  def update_with_sfdc_info
    Rails.logger.info '[INFO][User] ## //// UPDATE CURRENT USER WITH SFDC INFO //// ##'
    ApiModel.access_token = User.guest_access_token    
    sfdc_account = Account.find(username)
    self.access_token = refresh_user_access_token
    self.sfdc_username = sfdc_account.user.sfdc_username
    self.email = sfdc_account.user.email
    self.profile_pic = sfdc_account.user.profile_pic
    self.accountid = sfdc_account.user.accountid
    self.time_zone = sfdc_account.user.time_zone
    self.last_access_token_refresh_at = DateTime.now
    # user.skip_confirmation!
    Rails.logger.info "[FATAL][User] COULD NOT SAVE USER WITH SFDC INFO: #{user.errors.full_messages}" unless self.save
    # return the new access token
    access_token
  end

  def refresh_user_access_token
    Rails.logger.info "[INFO][User] %%%%% calling refresh_access_token_from_sfdc"
    auth_hash = mav_hash.nil? ? ENV['THIRD_PARTY_PASSWORD'] : Encryptinator.decrypt_string(mav_hash)
    sfdc_authentication = Account.new(self).authenticate(auth_hash)
    if sfdc_authentication.success.to_bool
      sfdc_authentication.access_token
    else
      # check for any authentication errors and return guest token if error
      Rails.logger.info "[FATAL][User] Could not refresh #{username}'s access token: #{sfdc_authentication.message}"
      User.guest_access_token
    end
  end  

  def plugins=(plugin_names)
    if persisted? # don't add plugins when the user_id is nil.
      UserPlugin.delete_all(:user_id => id)
      plugin_names.each_with_index do |plugin_name, index|
        plugins.create(:name => plugin_name, :position => index) if plugin_name.is_a?(String)
      end
    end
  end

  def authorized_plugins
    plugins.collect(&:name) | ::Refinery::Plugins.always_allowed.names
  end

  def can_delete?(user_to_delete = self)
    user_to_delete.persisted? &&
      !user_to_delete.has_role?(:superuser) &&
      ::Role[:refinery].users.any? &&
      id != user_to_delete.id
  end

  def can_edit?(user_to_edit = self)
    user_to_edit.persisted? && (
      user_to_edit == self ||
      self.has_role?(:superuser)
    )
  end

  def add_role(title)
    raise ArgumentException, "Role should be the title of the role not a role object." if title.is_a?(::Role)
    roles << ::Role[title] unless has_role?(title)
  end

  def has_role?(title)
    raise ArgumentException, "Role should be the title of the role not a role object." if title.is_a?(::Role)
    roles.any?{|r| r.title == title.to_s.camelize}
  end

  def create_first
    if valid?
      # first we need to save user
      save
      # add refinery role
      add_role(:refinery)
      # add superuser role
      add_role(:superuser) if ::Role[:refinery].users.count == 1
      # add plugins
      self.plugins = Refinery::Plugins.registered.in_menu.names
    end

    # return true/false based on validations
    valid?
  end

  def apply_omniauth(omniauth)
    if omniauth['info']
      self.email = omniauth['info']['email'] || "" if email.blank?
      self.username = omniauth["info"]["name"] || omniauth["info"]["nickname"] || ""      
    end
    self.password = self.password_confirmation = Devise.friendly_token[0,20]
    authentications.build(:provider => omniauth['provider'], :uid => omniauth['uid'])
  end

  def password_required?
    authentications.empty? && super
  end  

  def self.guest_access_token
    Rails.logger.info "[INFO][User] using guest access token"
    guest_token = Rails.cache.fetch('guest_access_token', :expires_in => ENV['MEMCACHE_EXPIRY'].to_i.minute) do
      client = Restforce.new :username => ENV['SFDC_PUBLIC_USERNAME'],
        :password       => ENV['SFDC_PUBLIC_PASSWORD'],
        :client_id      => ENV['SFDC_CLIENT_ID'],
        :client_secret  => ENV['SFDC_CLIENT_SECRET'],
        :host           => ENV['SFDC_HOST']
      client.authenticate!.access_token
    end
  end  

  def self.admin_access_token
    Rails.logger.info "[INFO][User] using admin access token for #{ENV['SFDC_ADMIN_USERNAME']}"
    guest_token = Rails.cache.fetch('guest_access_token', :expires_in => ENV['MEMCACHE_EXPIRY'].to_i.minute) do
      client = Restforce.new :username => ENV['SFDC_ADMIN_USERNAME'],
        :password       => ENV['SFDC_ADMIN_PASSWORD'],
        :client_id      => ENV['SFDC_CLIENT_ID'],
        :client_secret  => ENV['SFDC_CLIENT_SECRET'],
        :host           => ENV['SFDC_HOST']
      client.authenticate!.access_token
    end
  end   

end
