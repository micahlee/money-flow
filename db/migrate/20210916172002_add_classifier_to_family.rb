class AddClassifierToFamily < ActiveRecord::Migration[5.2]
  def change
    add_column :families, :classifier_data, :text, null: true
  end
end
