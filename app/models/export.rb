class Export < ActiveRecord::Base
  before_create :generate_hash

  def generate_hash
    begin
      download_hash = SecureRandom.hex
    end until Export.find_by(download_id: download_hash) == nil
    self.download_id = download_hash
  end
end
