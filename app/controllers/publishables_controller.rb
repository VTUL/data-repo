class PublishablesController < ApplicationController
  include Hydra::Catalog
  include Hydra::BatchEditBehavior
  include Hydra::Collections::SelectsCollections

  def index
    @publishables = []
    # there is almost certainly a better way to do this!!!
    Collection.where(depositor: current_user.user_key).each do |collection|    
      unless collection.member_ids.empty?
        unless collection.identifier.any? {|uri| uri.start_with? "doi:"}
          @publishables << collection
        end      
      end
    end
  end
end
