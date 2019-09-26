class AddCleared < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :cleared, :boolean, default: false
  end
end
