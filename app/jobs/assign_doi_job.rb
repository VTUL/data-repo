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
    minted_doi = Ezid::Identifier.create(
      datacite_creator: (asset.creator.empty? ? "" : asset.creator.first), 
      datacite_resourcetype: "Dataset",
      datacite_title: asset.title,
      datacite_publisher: (asset.publisher.empty? ? "" : asset.publisher.first), 
      datacite_publicationyear: (asset.date_created.empty? ? "" : asset.date_created.first)
     )
    asset[:identifier].each_with_index {
      |id, idx| id == "doi:pending" ? asset[:identifier][idx] = minted_doi.id : id
    }
    depositor = asset.depositor
    user = User.find_by_user_key(depositor)
    if (doi_request.update_attributes({:ezid_doi => minted_doi.id}) && 
      asset.update_attributes({:identifier => asset[:identifier]}))
      DoiMailer.notification_email(doi_request).deliver_later
    else
      User.batchuser.send_message(user, asset.errors.full_messages.join(', '), 'DOI Assign Error')
    end
  end
end
