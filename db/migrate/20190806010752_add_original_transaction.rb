class AddOriginalTransaction < ActiveRecord::Migration[5.2]
  def change
    add_reference :transactions, :split_from, foreign_key: { to_table: :transactions }
  end
end
