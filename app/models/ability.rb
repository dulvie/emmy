class Ability
  include CanCan::Ability
  def initialize(user)
    return nil unless user.try(:email)

    # Every signed in user can create a new organization.
    can :create, Organization
    can :manage, User

    roles = user.organization_roles
    staff_at = roles.select{ |role| role.name.eql?(OrganizationRole::ROLE_STAFF)}
    admin_at = roles.select{ |role| role.name.eql?(OrganizationRole::ROLE_ADMIN)}
    staff_at = staff_at.map{|r| r.organization_id}
    admin_at = admin_at.map{|r| r.organization_id}

    admin_roles_for(admin_at)
    staff_roles_for((staff_at + admin_at).uniq)
  end

  def admin_roles_for(oids)
    can :manage, Organization, id: oids
    can :manage, Warehouse, organization_id: oids
  end

  def staff_roles_for(oids)
    can :read, Organization, id: oids
    can :manage, Warehouse, organization_id: oids
  end
end
