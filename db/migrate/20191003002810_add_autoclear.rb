class AddAutoclear < ActiveRecord::Migration[5.2]
  def change
    add_column :funds, :auto_clear, :boolean, default: false
  end
end
