class CreateRefineryUser < ActiveRecord::Migration
  def up
    role = Role.new
    role.title = 'Refinery'
    role.save!
    role = Role.new
    role.title = 'Superuser'
    role.save!    
    user = User.create!(email: 'admin@example.com', password: 'madmin', username: 'admin')
    user.roles << Role.find_by_title('Refinery')
    user.roles << Role.find_by_title('Superuser')
  end

  def down
    user = User.find_by_email('admin@example.com')
    user.delete if user
    role = Role.find_by_title('Refinery')
    role.delete if role
    role = Role.find_by_title('Superuser')
    role.delete if role    
  end
end