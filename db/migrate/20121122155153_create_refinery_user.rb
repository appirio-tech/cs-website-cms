class CreateRefineryUser < ActiveRecord::Migration
  def up
    role = Role.new
    role.title = 'Superuser'
    role.save!
    user = User.create!(email: 'admin@example.com', password: 'madmin')
    user.roles << Role.find_by_title('Refinery')
    user.roles << Role.find_by_title('Superuser')
  end

  def down
    user = User.find_by_email('admin@example.com')
    user.delete if user
    role = Role.find_by_title('Superuser')
    role.delete if role
  end
end
