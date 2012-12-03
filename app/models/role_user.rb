class RoleUser < ActiveRecord::Base

	set_table_name :roles_users
	
  belongs_to :role
  belongs_to :user

end