class CreateTransactions < ActiveRecord::Migration[5.2]
  def change
    create_table :transactions do |t|
      t.references :account, foreign_key: true

      t.decimal :amount
      t.string :category
      t.string :category_id
      t.string :date

      t.string :iso_currency_code
      t.string :name
      t.boolean :pending
      t.string :transaction_id
      t.string :transaction_type
      
      t.timestamps
    end
  end
end
