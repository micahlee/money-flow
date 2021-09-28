class ArchivedDefault < ActiveRecord::Migration[5.2]
  def change

    # The 'archived column should not be null'
    Account.connection.execute("UPDATE accounts SET archived = false WHERE archived is null")
    change_column_default :accounts, :archived, to: false
    change_column_null :accounts, :archived, false

    Connection.connection.execute("UPDATE connections SET archived = false WHERE archived is null")
    change_column_default :connections, :archived, to: false
    change_column_null :connections, :archived, false

  end
end
