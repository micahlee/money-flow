class AddPaymentLinkToAccount < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :payment_link, :string
  end
end
