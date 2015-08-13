class Collection < Sufia::Collection

  property :funder, predicate: ::RDF::DC.provenance do |index|
    index.as :stored_searchable, :facetable
  end

end
