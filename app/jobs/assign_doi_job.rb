class AssignDoiJob
  attr_accessor :doi_request_id

  def queue_name
    :assign_doi
  end

  def initialize(doi_request_id)
    self.doi_request_id = doi_request_id
  end

  def run
    doi_request = DoiRequest.find(doi_request_id)
    asset = Collection.find(doi_request.asset_id)
    minted_doi = Ezid::Identifier.mint(
      datacite_creator: (asset.creator.empty? ? "" : asset.creator.first), 
      datacite_resourcetype: "Dataset",
      datacite_title: asset.title,
      datacite_publisher: (asset.publisher.empty? ? "" : asset.publisher.first), 
      datacite_publicationyear: (asset.date_created.empty? ? "" : asset.date_created.first)
     )
    doi = minted_doi.id
    id_array = asset.identifier.to_a
    id_array.each_with_index {
      |id, idx| id == "doi:pending" ? id_array[idx] = doi : id
    }
    asset.identifier = id_array
    doi_request.ezid_doi = doi
    if asset.save && doi_request.save
      DoiMailer.notification_email(doi_request).deliver_later
    else
      user = User.find_by_user_key(asset.depositor)
      User.batchuser.send_message(user, asset.errors.full_messages.join(', '), 'DOI Assign Error')
    end
  end
end
