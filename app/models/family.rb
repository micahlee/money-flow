class Family < ApplicationRecord
  has_and_belongs_to_many :users
  has_many :connections
  has_many :funds
end
