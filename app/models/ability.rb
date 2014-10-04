class Ability
  include CanCan::Ability
  def initialize(user)
    return nil unless user.try(:email)

    roles = user.organization_roles.roles_with_access
    admin_roles = roles.select{ |role| role.name.eql?(OrganizationRole::ROLE_ADMIN)}
    admin_at = admin_roles.map{|r| r.organization_id}
    admin_or_staff_at = roles.map{|r| r.organization_id}.uniq

    can(:manage, :all) if user.superadmin?

    admin_roles_for(admin_at)
    staff_roles_for(admin_or_staff_at)
  end

  def admin_roles_for(oids)
    can :manage, Organization, id: oids
  end

  def staff_roles_for(oids)
    can :manage, Batch, organization_id: oids
    can :manage, Comment, organization_id: oids
    can :manage, Contact, organization_id: oids
    can :manage, ContactRelation, organization_id: oids
    can :manage, Customer, organization_id: oids
    can :manage, Document, organization_id: oids 
    can :read, Organization, id: oids
    can :manage, Inventory, organization_id: oids
    can :manage, InventoryItem, organization_id: oids
    can :manage, Item, organization_id: oids
    can :manage, Purchase, organization_id: oids
    can :manage, PurchaseItem, organization_id: oids
    can :manage, Supplier, organization_id: oids
    can :manege, Unit, organization_id: oids
    can :manege, Vat, organization_id: oids
    can :manage, Warehouse, organization_id: oids
  end

end
