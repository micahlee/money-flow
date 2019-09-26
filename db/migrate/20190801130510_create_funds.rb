class CreateFunds < ActiveRecord::Migration[5.2]
  def change
    create_table :funds do |t|

      t.string :name
      t.references :account, foreign_key: true

      t.timestamps
    end
  end
end
