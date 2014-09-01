class Ability
  include CanCan::Ability

  def initialize(user)
    # Users without the roles method can't do anything.
    return nil unless user.try(:roles)

    admin_permissions(user) if user.role? :admin

    seller_permissions(user) if user.role? :seller

    # All users can manage self.
    can :manage, User do |user_to_manage|
      user_to_manage == user
    end
    # All users can read other users
    can :read, User
  end

  def admin_permissions(user)
    can :manage, User
    can :manage, Role
    can :manage, Organisation

    # :admin Also have seller permissions.
    seller_permissions(user)
  end

  def seller_permissions(user)
    can :manage, Comment
    can :manage, Contact
    can :manage, ContactRelation
    can :manage, Customer
    can :manage, Batch
    can :manage, Document
    can :manage, Import
    can :manage, Inventory
    can :manage, InventoryItem
    can :manage, Item
    can :manage, Manual
    can :manage, Material
    can :manage, Production
    can :manage, Purchase
    can :manage, PurchaseItem
    can :manage, Transfer
    can :manage, Supplier
    can :manage, Sale
    can :manage, SaleItem
    can :manage, Unit
    can :manage, Vat
    can :manage, Warehouse
    can :manage, Shelf
    can :read, Statistics::Report
  end

end
