class CreateJoinTableFamilyUser < ActiveRecord::Migration[5.2]
  def change
    create_join_table :families, :users do |t|
      t.index [:family_id, :user_id]
    end
  end
end
