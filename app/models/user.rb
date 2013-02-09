class User < ActiveRecord::Base
  has_and_belongs_to_many :roles, :join_table => :roles_users
  has_many :plugins, :class_name => "UserPlugin", :order => "position ASC", :dependent => :destroy

  has_many :authentications

  devise :database_authenticatable, :registerable, :timeoutable,
         :recoverable, :rememberable, :validatable,
         :token_authenticatable, :confirmable, :lockable
         # :trackable,  

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :username
  # attr_accessible :title, :body

  validates :username, :presence => true

  def create_account
    # not sure if we need this?
    # resp = account.create
    # if resp.success == "true"
    #   self.sfdc_username = resp.sfdc_username
    # else
    #   errors.add :account, resp.message
    # end
    # resp.success == "true"
  end

  def account
    @acount ||= Account.new(self)
  end

  def challenge_admin?(challenge) 
    challenge_sponsor?(challenge) || appirio?
  end  

  def challenge_sponsor?(challenge)
    accountid == challenge.account
  end  

  def appirio?
    email.include?('@appirio.com')
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
end
