class DoiRequest < ActiveRecord::Base

  #DOI_REGEX = //i
  ASSET_TYPES = ['Collection', 'GenericWork']
  validates :asset_type, :presence => true,
                         :inclusion => { :in => ASSET_TYPES,
    :message => "must be in #{ASSET_TYPES.join(', ')}" }
  validates_uniqueness_of :collection_id, :scope => :asset_type
  validates_presence_of :ezid_doi
  #validates_format_of :ezid_doi, :with => DOI_REGEX
  
  scope :completed, lambda { where(:completed => true) }
  scope :pending, lambda { where(:completed => false) }
  scope :sorted, lambda { order("doi_requests.created_at ASC") }
  scope :with_asset_type, lambda {|atype|
    where(:asset_type => atype) 
  }

  scope :search, lambda { |query|
    where(["doi_id LIKE ?", "%#{query}%"])
  }

end

