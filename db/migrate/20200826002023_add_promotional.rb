class AddPromotional < ActiveRecord::Migration[5.2]
  def change
    create_table :promotional_transactions do |t|
      t.references :transaction, foreign_key: true
      t.date :due 
    end
  end
end
