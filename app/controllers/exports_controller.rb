class ExportsController < ApplicationController

  def index
    redirect_to root_path, alert: "Sorry, you are not authorized to view that page" if (current_user.blank? || !current_user.admin?)
    @exports = Export.all
  end

  def download
    download_id = params[:download_id]
    export = Export.find_by(download_id: download_id)
    redirect_message = nil
    if export.nil?
      redirect_message = "Could not find any associated export request"
    elsif !export.nil? && (current_user.blank? || export.user_id != current_user.id)
      redirect_message = "Sorry, you are not authorized to view this export. Are you logged in?"
    end
    if redirect_message.nil?
      exports_dir = File.join(Rails.root.to_s, 'tmp', 'exports')
      export_path = File.join(exports_dir, export.filename)
      send_data File.read(export_path), filename: export.filename

      # clean up
      GC.start
      File.delete(export_path)
      export.destroy

    else
      redirect_to root_path, alert: redirect_message
    end
  end

end

