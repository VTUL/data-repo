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
    ezid_shoulder = Rails.application.secrets['ezid']['default_shoulder']
    cannot [:update, :destroy], ::Collection do |c|
      c.identifier.any? {|id| id.start_with?(ezid_shoulder)}
    end unless admin_user?

    cannot [:update, :destroy], ::GenericFile do |g_f|
      g_f.collections.any? { |c| c.identifier.any? {|id| id.start_with?(ezid_shoulder)}}
    end unless admin_user?

    if admin_user?
      can [:create, :show, :add_user, :remove_user, :index], Role
      can [:index, :pending, :mint_doi, :view_doi, :mint_all], DoiRequest
    end
    can :manage, :all if admin_user?
  end

end
