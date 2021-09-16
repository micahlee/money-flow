# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    can :read, Family do |family|
      family.users.include?(user)
    end

    can :update, Family do |family|
      family.users.include?(user)
    end

    can :read, Connection do |conn|
      can? :read, conn.family
    end

    can :update, Connection do |conn|
      can? :update, conn.family
    end

    can :read, Account do |account|
      can? :read, account.connection
    end

    can :update, Account do |account|
      can? :update, account.connection
    end

    can :read, Fund do |fund|
      can? :read, fund.family
    end

    can :update, Fund do |fund|
      can? :update, fund.family
    end

    can :read, Transaction do |transaction|
      can? :read, transaction.account
    end

    can :update, Transaction do |transaction|
      can? :read, transaction.account
    end

    can :sync, Family do |family|
      # Currently, all that's required to sync a families accounts
      # is to also be able to read the family.
      can? :read, family
    end

    can :sync, Connection do |conn|
      can? :sync, conn.family
    end

    can :sync, Account do |account|
      can? :sync, account.connection
    end
    
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities
  end
end
