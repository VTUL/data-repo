class ExportSearchBuilder < Blacklight::SearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior
  include Hydra::AccessControlsEnforcement

  self.default_processor_chain = [:collections]

  def all_collections(solr_parameters)
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << "{!field f=has_model_ssim v=Collection}"
    solr_parameters[:rows] = 1000000
  end

  def collections_by_file_id(solr_parameters)
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << "{!field f=has_model_ssim v=Collection}"
    solr_parameters[:fq] << "{!field f=hasCollectionMember_ssim v=8k71nh08w}"
    solr_parameters[:rows] = 1000
  end

  def all_generic_files(solr_parameters)
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << "{!field f=has_model_ssim v=GenericFile}"
    solr_parameters[:rows] = 1000000
  end

end
