# Generated via
#  `rails generate curation_concerns:work Item`
module CurationConcerns
  class ItemForm < Sufia::Forms::WorkForm
    self.model_class = ::Item
    self.terms += [:resource_type]

  end
end
