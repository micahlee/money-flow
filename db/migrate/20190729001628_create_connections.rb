class CreateConnections < ActiveRecord::Migration[5.2]
  def change
    create_table :connections do |t|

      t.string :name
      t.string :access_token
      t.string :item_id

      t.timestamps
    end
  end
end
