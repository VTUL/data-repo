module DoiRequestsHelper

  def status_tag(boolean, options={})
    options[:true_text] ||= ''
    options[:false_text] ||= ''

    if boolean
      content_tag(:span, options[:true_text], :class => 'status true')
    else
      content_tag(:span, options[:false_text], :class => 'status false')
    end
  end

  def doi_link_for(doi_request)
    if doi_request.collection?
      if Collection.exists?(id: doi_request.asset_id)
        collection = Collection.find(doi_request.asset_id)
        link_to collection.title, collections.collection_path(collection), title: "Show this Dataset"
      else
        "Deleted Dataset"
      end
    else
      link_to 'Unknown asset', '#'
    end
  end

  def button_to_requests(scope)
    if scope == 'pending'
      button_to "All Requests", doi_requests_path, method: :get, class: "btn btn-default"
    else
      button_to "Pending Requests", pending_doi_requests_path, method: :get, class: "btn btn-default"
    end
  end
end

