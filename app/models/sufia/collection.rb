module Sufia
  class Collection < ActiveFedora::Base
    include Sufia::CollectionBehavior

    before_destroy :delete_doi_requests

    def delete_doi_requests
      requests = DoiRequest.where(asset_id: self.id)
      if !requests.empty?
        requests.each do |request|
          request.destroy
        end
      end
    end

    def csv_headers
      ['id', 'title', 'creator', 'contributor', 'abstract', 'keyword', 'rights', 'publisher', 'date_created', 'subject', 'language', 'identifier', 'location', 'related_url', 'funding_info', 'items']
    end

    def admin_csv_headers
      admin_solr_headers.concat admin_fedora_headers
    end

    def admin_solr_headers
      ["system_create_dtsi", "system_modified_dtsi", "active_fedora_model_ssi", "has_model_ssim", "object_profile_ssm", "depositor_ssim", "depositor_tesim", "title_tesim", "description_tesim", "publisher_tesim", "publisher_sim", "resource_type_tesim", "resource_type_sim", "identifier_tesim", "hasCollectionMember_ssim", "read_access_group_ssim", "edit_access_person_ssim"]
    end

    def admin_fedora_headers
      ["id", "depositor", "part_of", "contributor", "creator", "title", "description", "publisher", "date_created", "date_uploaded", "date_modified", "subject", "language", "rights", "resource_type", "identifier", "based_near", "tag", "related_url", "funder", "member_ids"]
    end

    def admin_csv_values
      ret_array = []
      solr_record = self.to_solr
      admin_solr_headers.each do | key |
        value = !solr_record[key].blank? ? solr_record[key] : ""
        ret_array << (value.respond_to?("each") ? value.join("||") : value)
      end
      admin_fedora_headers.each do | key |
        value = !self.send(key).blank? ? self.send(key) : ""
        ret_array << (value.respond_to?("each") ? value.join("||") : value)
      end
      ret_array
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
