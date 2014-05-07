class Ability
  include CanCan::Ability

  def initialize(user)
    return nil unless user.try(:roles)

    admin_permissions(user) if user.role? :admin

    seller_permissions(user) if user.role? :seller

    # All users can manage self.
    can :manage, User do |user_to_manage|
      user_to_manage == user
    end
  end

  def admin_permissions(user)
    can :manage, User
    can :manage, Role

    # :admin Also have seller permissions.
    seller_permissions(user)
  end

  def seller_permissions(user)
    can :manage, ContactInfo
    can :manage, Customer
    can :manage, Manual
    can :manage, Product
    can :manage, Transaction
    can :manage, Transfer
    can :manage, Supplier
    can :manage, Warehouse
    can :read, Statistics::Report
  end


end
