class ArchiveConnection < ActiveRecord::Migration[5.2]
  def change
    add_column :connections, :archived, :boolean
  end
end
