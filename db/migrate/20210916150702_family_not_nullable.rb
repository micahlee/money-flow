class FamilyNotNullable < ActiveRecord::Migration[5.2]
  def change
    change_column_null :connections, :family_id, false
    change_column_null :funds, :family_id, false
  end
end
