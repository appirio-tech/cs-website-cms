class User < ActiveRecord::Base
  has_and_belongs_to_many :roles, :join_table => :roles_users
  has_many :plugins, :class_name => "UserPlugin", :order => "position ASC", :dependent => :destroy

  devise :database_authenticatable, :registerable, :timeoutable,
    :recoverable, :rememberable, :validatable,
    :omniauthable, :token_authenticatable, :confirmable, :lockable
  # :trackable,

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me,
    :username, :provider, :uid
  # attr_accessible :title, :body

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

  def self.find_for_oauth(auth, signed_in_resource=nil)
    user = User.where(:provider => auth.provider, :uid => auth.uid).first
    unless user
      user = User.create(provider:auth.provider,
                         uid:auth.uid,
                         email:auth.info.email || "#{auth.uid}@#{auth.provider}.com",
                         # NOTE: twitter and github does not have any email address in its auth response
                         # NOTE: If we need to contact these users, we may need to ask them to provide their
                         #       email addresses as part of their profiles / sign-up process
                         password:Devise.friendly_token[0,20],
                         )
      user.skip_confirmation!
      user.save!
    end
    user
  end

end
