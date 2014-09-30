class Ability
  include CanCan::Ability
  def initialize(user)
    return nil unless user.try(:name)
    can :create, Organization
  end
end
