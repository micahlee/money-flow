class AddLastSyncError < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :last_sync_error_at, :datetime, null: true
    add_column :accounts, :last_sync_error, :text, null: true

  end
end
