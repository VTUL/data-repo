module Sufia
  class Collection < ActiveFedora::Base
    include Sufia::CollectionBehavior

    def csv_headers
      ['id', 'title', 'creator', 'contributor', 'abstract', 'keyword', 'rights', 'publisher', 'date_created', 'subject', 'language', 'identifier', 'location', 'related_url', 'funding_info', 'items']
    end

    def csv_values
      ret_array = []
      ret_array << self.id
      ret_array << self.title
      ret_array << self.creator.join('||')
      ret_array << self.contributor.join('||')
      ret_array << self.description
      ret_array << self.tag.join('||')
      ret_array << self.rights.join('||')
      ret_array << self.publisher.join('||')
      ret_array << self.date_created.join('||')
      ret_array << self.subject.join('||')
      ret_array << self.language.join('||')
      ret_array << self.identifier.join('||')
      ret_array << self.based_near.join('||')
      ret_array << self.related_url.join('||')
      ret_array << self.funder.join('||')
      ret_array << self.member_ids.join('||')
    end

  end
end
