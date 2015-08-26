module SufiaHelper
  include ::BlacklightHelper
  include Sufia::BlacklightOverride
  include Sufia::SufiaHelperBehavior

  def request_doi_link(asset)
    if asset[:identifier].empty? 
      form_tag url_for(:controller => 'doi_requests', :action => 'create', :asset_id => asset.id, :asset_type => asset.class.to_s) do
        submit_tag "Request DOI", :title => "Make a request to obtain a DOI for this Collection" 
      end
    else
      asset[:identifier].each do |id|
        if id == t('doi.pending_doi')
          return "<br/>DOI request is pending...".html_safe
        end
      end
      return
    end
  end
end
