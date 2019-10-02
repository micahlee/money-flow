class AddExcludeFromAvailable < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :exclude_from_available, :boolean, default: false
  end
end
