class CreateAccounts < ActiveRecord::Migration[5.2]
  def change
    create_table :accounts do |t|
      t.references :connection, foreign_key: true

      t.string :account_id, index: true
      t.decimal :balance_current
      t.decimal :balance_available
      t.string :iso_currency_code
      t.string :name
      t.string :official_name
      t.string :account_type
      t.string :account_subtype
      t.string :mask

      t.boolean :archived
      
      t.timestamps
    end
  end
end
