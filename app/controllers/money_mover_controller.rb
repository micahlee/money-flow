
class MoneyMoverController < ApplicationController

  Flow = Struct.new(:from, :to)
  Transfer = Struct.new(:amount, :comment)
  Total = Struct.new(:from, :to, :amount)

  def index
    cycle = params[:cycle]

    accounts = money_mover_config['accounts']
    dates = money_mover_config['transfers'].keys.map(&:to_s)
    transactions = money_mover_config['transfers'][cycle.to_i]
    transfers = Hash.new {|h,k| h[k] = [] }

    transactions.each do |t|
      transfers[Flow.new(t[0], t[1])].push(Transfer.new(t[2], t[3]))
    end

    @totals = transfers.map do |flow, transfers|
      sum = transfers.inject(0){ |sum,x| sum + (x.amount * 100) }
      from = accounts[flow.from]
      to = accounts[flow.to]
      
      Total.new(from, to, sum)
    end
  end

  private

  def money_mover_config
    authorize! :read, Family.find(1)
    @money_mover_config ||= YAML.load_file("#{Rails.root.to_s}/config/money_mover.yml")
  end
end
