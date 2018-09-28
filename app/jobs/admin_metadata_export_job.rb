class AdminMetadataExportJob
  require 'vtech_data/download_generator'

  attr_accessor :base_path
  attr_accessor :current_user

  def queue_name
    :admin_metadata_export
  end

  def initialize base_path, current_user
    self.current_user = current_user
    self.base_path = base_path
  end

  def run
    time_stamp = DateTime.now.strftime("%F_%H%M%S")
    csv_generator = DownloadGenerator.new(time_stamp)
    csv_generator.make_archive
    csv_generator.generate_all_metadata('Collection')
    csv_generator.generate_all_metadata('GenericFile')
    filename = csv_generator.archive_name
    csv_generator.zip
    csv_generator.remove_tmp_folder

    export = Export.create(user_id:current_user.id, filename: "#{filename}.zip")
    MetadataExportMailer.notification_email(current_user, export.download_id, base_path).deliver_later
  end
end
