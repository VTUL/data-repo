class PublishablesController < ApplicationController
  include Hydra::Catalog
  include Hydra::BatchEditBehavior
  include Hydra::Collections::SelectsCollections

  def index
    @publishables = []
    Collection.where(depositor: Rack::Utils.escape(current_user)).each do |collection|
      unless collection.member_ids.empty? or collection.identifier.any? {|uri| uri.start_with? "doi:"}
        @publishables << collection
      end
    end
  end
end
