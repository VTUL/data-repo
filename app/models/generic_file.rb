class GenericFile < ActiveFedora::Base
  include Sufia::GenericFile

  property :provenance, predicate: ::RDF::Vocab::DC.provenance do |index|
    index.type :text
    index.as :stored_searchable
  end

  def csv_headers
    ['id', 'mime_type', 'file_size', 'filename', 'checksum', 'depositor', 'title', 'resource_type', 'keyword', 'creator', 'rights', 'contributor', 'abstract', 'date_created', 'subject', 'language', 'identifier', 'location', 'related_url', 'provenance', 'in_collections']
  end

  def csv_values
    ret_array = []
    collections = self.collections.map{ |c| c.id }.join('||') rescue ""
    ret_array << self.id
    ret_array << self.mime_type
    ret_array << self.file_size.join('||')
    ret_array << self.filename.join('||')
    ret_array << self.original_checksum.join('||')
    ret_array << self.depositor
    ret_array << self.title.join('||')
    ret_array << self.resource_type.join('||')
    ret_array << self.tag.join('||')
    ret_array << self.creator.join('||')
    ret_array << self.rights.join('||')
    ret_array << self.contributor.join('||')
    ret_array << self.description.join('||')
    ret_array << self.date_created.join('||')
    ret_array << self.subject.join('||')
    ret_array << self.language.join('||')
    ret_array << self.identifier.join('||')
    ret_array << self.based_near.join('||')
    ret_array << self.related_url.join('||')
    ret_array << self.provenance.join('||')
    ret_array << collections
  end
end

