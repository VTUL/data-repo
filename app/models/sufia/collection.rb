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

    def admin_csv_values solr_record
      ret_array = []
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

    def csv_values record
      record_obj = record['object_profile_ssm']
      ret_array = []
      ret_array << record_obj['id']
      ret_array << record_obj['title']
      ret_array << record_obj['creator'].join('||')
      ret_array << record_obj['contributor'].join('||')
      ret_array << record_obj['description']
      ret_array << record_obj['tag'].join('||')
      ret_array << record_obj['rights'].join('||')
      ret_array << record_obj['publisher'].join('||')
      ret_array << record_obj['date_created'].join('||')
      ret_array << record_obj['subject'].join('||')
      ret_array << record_obj['language'].join('||')
      ret_array << record_obj['identifier'].join('||')
      ret_array << record_obj['based_near'].join('||')
      ret_array << record_obj['related_url'].join('||')
      ret_array << record_obj['funder'].join('||')
      ret_array << record_obj['member_ids'].join('||')
    end

  end
end
