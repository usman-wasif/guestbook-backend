class RenameAdminsTableToAdminUsersTable < ActiveRecord::Migration[7.1]
  def change
    rename_table :admins, :admin_users
  end
end