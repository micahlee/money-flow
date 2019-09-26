class HideFromSnapshot < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :hidden_from_snapshot, :boolean, default: false
  end
end
