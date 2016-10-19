class GenericFile < ActiveFedora::Base
  include Sufia::GenericFile

  property :provenance, predicate: ::RDF::Vocab::DC.provenance do |index|
    index.type :text
    index.as :stored_searchable
  end
end

