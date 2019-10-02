class AddLastSuccessfulSync < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :last_synced_at, :datetime, null: true
  end
end
