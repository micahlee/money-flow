class AddAssignedFund < ActiveRecord::Migration[5.2]
  def change
    add_reference :transactions, :fund, foreign_key: true
  end
end
