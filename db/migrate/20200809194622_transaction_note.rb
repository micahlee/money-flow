class TransactionNote < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :note, :text
  end
end
