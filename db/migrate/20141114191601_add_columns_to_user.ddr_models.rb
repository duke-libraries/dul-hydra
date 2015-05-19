# This migration comes from ddr_models (originally 20141107124012)
class AddColumnsToUser < ActiveRecord::Migration
  def up
    if table_exists?("users")
      unless column_exists?("users", "username")
        add_column "users", "username", :string, default: "", null: false
      end
      unless column_exists?("users", "first_name")
        add_column "users", "first_name", :string
      end
      unless column_exists?("users", "middle_name")
        add_column "users", "middle_name", :string
      end
      unless column_exists?("users", "nickname")
        add_column "users", "nickname", :string
      end
      unless column_exists?("users", "last_name")
        add_column "users", "last_name", :string
      end
      unless column_exists?("users", "display_name")
        add_column "users", "display_name", :string
      end

      # If the email index exists and is set such that email must be unique (which is the initial
      # setting typically set by Devise(?)), remove and we'll re-add it as non-unique below.
      if index_exists?("users", ["email"])
        if index_exists?("users", ["email"], unique: true)
          remove_index "users", ["email"]
        end
      end

      # Either the email index didn't exist when we started or, more likely, we removed above
      # because it existed but required email to be unique.
      unless index_exists?("users", ["email"])
        add_index "users", ["email"], name: "index_users_on_email"
      end

      unless index_exists?("users", ["username"])
        add_index "users", ["username"], name: "index_users_on_username", unique: true
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
