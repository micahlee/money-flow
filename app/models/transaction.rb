require "base64"

class Transaction < ApplicationRecord
  belongs_to :account
  belongs_to :fund, optional: true
  
  belongs_to :split_from, optional: true, class_name: 'Transaction', foreign_key: 'transaction_id'

  has_one :promotional_transaction

  def suggested_funds
    fund_classifier.classifications(classification_text)
                   .map{ |k,v| [k, v] }
                   .sort_by { |row| row[1] }
                   .reverse[0...2]
                   .map{ |row| {
                     fund: Fund.where('lower(name) = ?', row[0].downcase).first,
                     score: row[1]
                     }
                   }
  end

  def classification_text
    [
      account.connection.name,
      account.name,
      category,
      name
    ].join(' ')
  end

  def fund_classifier
    @fund_classifier ||= Marshal.load(
      Base64.decode64(
        account.connection.family.classifier_data
      )
    )
  end

end
