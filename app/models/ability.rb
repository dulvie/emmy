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
    can :manage, Comment
    can :manage, Contact
    can :manage, Customer
    can :manage, Manual
    can :manage, Product
    can :manage, ProductTransaction
    can :manage, Purchase
    can :manage, PurchaseItem
    can :manage, Transfer
    can :manage, Supplier
    can :manage, Sale
    can :manage, SaleItem
    can :manage, Warehouse
    can :read, Statistics::Report
  end


end
