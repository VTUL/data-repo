class DoiRequest < ActiveRecord::Base

  ASSET_TYPES = ['Collection', 'GenericWork']
  validates :asset_type, :presence => true,
                         :inclusion => { :in => ASSET_TYPES,
    :message => "must be in #{ASSET_TYPES.join(', ')}" }
  validates_uniqueness_of :asset_id, :scope => :asset_type
  validates_presence_of :ezid_doi
  
  scope :pending, lambda { where(:ezid_doi => "doi:pending") }
  scope :sorted, lambda { order("doi_requests.created_at ASC") }
  scope :with_asset_type, lambda {|atype|
    where(:asset_type => atype) 
  }

  def completed?
    return self.ezid_doi != "doi:pending"
  end

  def collection?
    return self.asset_type == "Collection"
  end

end

