module DoiRequestsHelper

  def status_tag(doi_request, options={})
    options[:true_text] ||= ''
    options[:false_text] ||= ''

    if doi_request.completed?
      content_tag(:span, options[:true_text], :class => 'status true')
    else
      content_tag(:span, options[:false_text], :class => 'status false')
    end
  end

  def request_box_tag(doi_request)
    check_box_tag "doi_requests_checkbox[]", doi_request.id, false, class: "doi_request_selector", id: "doi_request_#{doi_request.id}", disabled: doi_request.completed?
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

  def mint_or_view_doi_button(doi_request)
    if doi_request.completed?
      link_to t('doi.view'), view_doi_doi_request_path(doi_request), class: "btn btn-default pull-left margin-right-sm"
    else
      link_to t('doi.mint'), mint_doi_doi_request_path(doi_request), method: :patch, class: "btn btn-default pull-left margin-right-sm"
    end
  end

  def admin_dataset_download doi_request
    collection = Collection.find(doi_request["asset_id"]) rescue nil
    if(!collection.nil?)
      return link_to "Download dataset", collections_download_path(collection, 'admin'), class: "btn btn-default pull-left margin-right-sm"
    else
      return ""
    end
  end
end

