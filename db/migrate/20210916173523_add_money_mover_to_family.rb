class AddMoneyMoverToFamily < ActiveRecord::Migration[5.2]
  def change
    add_column :families, :money_mover_yaml, :text, null: true
  end
end
