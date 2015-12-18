class Ability
  include CanCan::Ability
  def initialize(user)
    if user.role == 'admin'
        can :manage, :all
    elsif user.role == 'ens_viewer'
        can :index, Ticket
        can :manage, Subscription, :user_id => user.id
        cannot :read, [Subscription, Category, Property]
    elsif user.role = 'ens_admin'
        can :manage, Ticket
        can :manage, Subscription, :user_id => user.id
        cannot :read, [Subscription, Category, Property]
    end
  end
end
