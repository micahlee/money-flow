class AddFundsToFamilies < ActiveRecord::Migration[5.2]
  def change
    add_reference :funds, :family
  end
end
