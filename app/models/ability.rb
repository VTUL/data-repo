class Ability
  include Hydra::Ability
  include Sufia::Ability

  # Define any customized permissions here.
  def custom_permissions
    # Limits deleting objects to a the admin user
    #
    # if current_user.admin?
    #   can [:destroy], ActiveFedora::Base
    # end

    # Limits creating new objects to a specific group
    #
    # if user_groups.include? 'special_group'
    #   can [:create], ActiveFedora::Base
    # end
    ezid_shoulder = Rails.application.secrets['doi']['default_shoulder']
    cannot [:create, :update, :destroy], ::Collection do |c|
      c.identifier.any? { |identifier| !identifier.blank? }
    end unless admin_user?

    cannot [:create, :update, :destroy], ::GenericFile do |g_f|
      g_f.collections.any? { |c| c.identifier.any? { |identifier| !identifier.blank? } }
    end unless admin_user?

    can :manage, :all if admin_user?
  end
end
