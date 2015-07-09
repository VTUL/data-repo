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
      if Collection.exists?(id: doi_request.collection_id)
        collection = Collection.find(doi_request.collection_id)
        link_to collection.title, collections.collection_path(collection), title: "Show this Collection"
      else
        "Deleted Collection!"
      end
    else
      link_to 'Unknown asset', '#'
    end
  end
end

