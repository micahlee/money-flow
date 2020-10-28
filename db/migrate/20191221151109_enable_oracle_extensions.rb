class EnableOracleExtensions < ActiveRecord::Migration[5.2]
  def up
    execute "CREATE EXTENSION orafce;" 
  end
end
