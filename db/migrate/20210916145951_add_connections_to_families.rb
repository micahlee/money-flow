class AddConnectionsToFamilies < ActiveRecord::Migration[5.2]
  def change
    add_reference :connections, :family
  end
end
