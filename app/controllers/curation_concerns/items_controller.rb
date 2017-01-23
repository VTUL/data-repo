# Generated via
#  `rails generate curation_concerns:work Item`

module CurationConcerns
  class ItemsController < ApplicationController
    include CurationConcerns::CurationConcernController
    # Adds Sufia behaviors to the controller.
    include Sufia::WorksControllerBehavior

    self.curation_concern_type = Item
  end
end
