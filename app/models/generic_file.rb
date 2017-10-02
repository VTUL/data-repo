class GenericFile < ActiveFedora::Base
  include Sufia::GenericFile

  property :provenance, predicate: ::RDF::Vocab::DC.provenance do |index|
    index.type :text
    index.as :stored_searchable
  end

  def csv_headers
    ['id', 'mime_type', 'file_size', 'filename', 'checksum', 'depositor', 'title', 'resource_type', 'keyword', 'creator', 'rights', 'contributor', 'abstract', 'date_created', 'subject', 'language', 'identifier', 'location', 'related_url', 'provenance', 'in_collections']
  end

  def admin_csv_headers
    admin_solr_headers.concat admin_fedora_headers
  end

  def admin_solr_headers
    ["system_create_dtsi", "system_modified_dtsi", "active_fedora_model_ssi", "has_model_ssim", "object_profile_ssm", "mime_type_tesim", "depositor_ssim", "depositor_tesim", "resource_type_tesim", "resource_type_sim", "title_tesim", "title_sim", "creator_tesim", "creator_sim", "contributor_tesim", "contributor_sim", "description_tesim", "tag_tesim", "tag_sim", "rights_tesim", "date_created_tesim", "date_uploaded_dtsi", "date_modified_dtsi", "subject_tesim", "subject_sim", "language_tesim", "language_sim", "identifier_tesim", "based_near_tesim", "based_near_sim", "related_url_tesim", "isPartOf_ssim", "label_tesim", "file_format_tesim", "file_format_sim", "all_text_timv", "file_size_is", "digest_ssim", "read_access_group_ssim", "edit_access_person_ssim"]
  end

  def admin_fedora_headers
    ["id", "mime_type", "format_label", "file_size", "last_modified", "filename", "original_checksum", "rights_basis", "copyright_basis", "copyright_note", "well_formed", "valid", "status_message", "file_title", "file_author", "page_count", "file_language", "word_count", "character_count", "paragraph_count", "line_count", "table_count", "graphics_count", "byte_order", "compression", "color_space", "profile_name", "profile_version", "orientation", "color_map", "image_producer", "capture_device", "scanning_software", "exif_version", "gps_timestamp", "latitude", "longitude", "character_set", "markup_basis", "markup_language", "bit_depth", "channels", "data_format", "offset", "frame_rate", "label", "depositor", "arkivo_checksum", "relative_path", "import_url", "part_of", "resource_type", "title", "creator", "contributor", "description", "tag", "rights", "date_created", "date_uploaded", "date_modified", "subject", "language", "identifier", "based_near", "related_url", "bibliographic_citation", "source", "proxy_depositor", "on_behalf_of", "provenance", "batch_id"]
  end

  def admin_csv_values
    ret_array = []
    admin_solr_headers.each do | key |
      value = !self.to_solr[key].blank? ? self.to_solr[key] : ""
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

