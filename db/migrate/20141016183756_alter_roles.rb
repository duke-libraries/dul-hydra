class AlterRoles < ActiveRecord::Migration
  def change
    drop_table :roles do |t|
      # must have block to be reversible
    end
    drop_table :roles_users do |t|
      # must have block to be reversible
    end
  end
end
