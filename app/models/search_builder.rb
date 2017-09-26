class SearchBuilder < Blacklight::SearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior
  include Hydra::AccessControlsEnforcement
  include Sufia::SearchBuilder

  # Override Hydra::AccessControlsEnforcement (or Hydra::PolicyAwareAccessControlsEnforcement)
  # Allows admin users to see everything (don't apply any gated_discovery_filters for those users)
  def gated_discovery_filters(permission_types = discovery_permissions, ability = current_ability)
    return [] if ability.current_user.admin?
    super
  end
end
