class EnableTablefuncExtension < ActiveRecord::Migration[5.2]
  def up
    execute "CREATE EXTENSION IF NOT EXISTS tablefunc;" 
  end
end
