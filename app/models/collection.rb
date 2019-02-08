class Collection < Sufia::Collection

  property :funder, predicate: ::RDF::DC.provenance do |index|
    index.as :stored_searchable, :facetable
  end

  property :citation, predicate: ::RDF::DC.bibliographicCitation, multiple: false do |index|
    index.as :stored_searchable
  end

end
