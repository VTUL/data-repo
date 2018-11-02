class DashboardController < ApplicationController
  include Sufia::DashboardControllerBehavior

  def admin_metadata_download
    repository = CatalogController.new.repository
    builder = ExportSearchBuilder.new([:collections_by_file_id], repository).with(hasCollectionMember_ssim: 'Abraham Lincoln')
    response = repository.search(builder)
    Sufia.queue.push(AdminMetadataExportJob.new(request.base_url, current_user))
    redirect_to sufia.dashboard_index_path, notice: 'Your export is running in the background. You should receive an email when it is complete.'    
  end

end
