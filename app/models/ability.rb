class Ability
  include CanCan::Ability
  def initialize(user, current_organization=nil)
    return nil unless user.try(:email)
    @current_organization = current_organization

    # a user can manage self.
    can :manage, User, id: user.id

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
    if @current_organization && oids.include?(@current_organization.id)
      can :create, User
    end
  end

  def staff_roles_for(oids) 
    can :manage, Batch, organization_id: oids
    can :manage, Comment, organization_id: oids
    can :manage, Contact, organization_id: oids
    can :manage, ContactRelation, organization_id: oids
    can :manage, Customer, organization_id: oids
    can :manage, Document, organization_id: oids 
    can :read, Organization, id: oids
    can :manage, Import, organization_id: oids
    can :manage, Inventory, organization_id: oids
    can :manage, InventoryItem, organization_id: oids
    can :manage, Item, organization_id: oids
    can :manage, Manual, organization_id: oids
    can :manage, Material, organization_id: oids
    can :manage, Production, organization_id: oids
    can :manage, Purchase, organization_id: oids
    can :manage, PurchaseItem, organization_id: oids
    can :manage, Sale, organization_id: oids
    can :manage, SaleItem, organization_id: oids
    can :manage, Shelf, organization_id: oids
    can :manage, Supplier, organization_id: oids
    can :manage, Transfer, organization_id: oids
    can :manage, Unit, organization_id: oids

    can :manage, Vat, organization_id: oids
    can :manage, Warehouse, organization_id: oids
  end

end
