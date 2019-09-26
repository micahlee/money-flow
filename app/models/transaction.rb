class Transaction < ApplicationRecord
  belongs_to :account
  belongs_to :fund, optional: true
  
  belongs_to :split_from, optional: true, class_name: 'Transaction', foreign_key: 'transaction_id'
end
