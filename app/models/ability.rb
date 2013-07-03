class Ability
  include CanCan::Ability

  def initialize(user)
    return nil unless user.try(:roles)

    admin_permissions(user) if user.role? :admin
    can :manage, Warehouse

    can :manage, User do |user_to_manage|
      user_to_manage == user
    end

  end

  def admin_permissions(user)
    can :manage, User
  end

end
