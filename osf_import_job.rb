class OsfImportJob
  require 'vtech_data/osf_import_tools'
  attr_accessor :oauth_token
  attr_accessor :project_id
  attr_accessor :current_user

  def queue_name
    :osf_import
  end

  def initialize(oauth_token, project_id, current_user)
    self.oauth_token = oauth_token
    self.project_id = project_id
    self.current_user = current_user
  end

  def run
    osf_import_tools = OsfImportTools.new(oauth_token, current_user)
    osf_import_tools.import_project project_id
  end
end
