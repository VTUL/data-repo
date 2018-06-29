class DepositorExportJob
  require 'securerandom'

  attr_accessor :current_user
  attr_accessor :base_path

  def queue_name
    :depositor_export
  end

  def initialize(current_user, base_path)
    self.current_user = current_user
    self.base_path = base_path
  end

  def run
    attributes = %w{email name filename file_id datasets dataset_ids}

    export_dir = File.join(Rails.root.to_s, 'tmp', 'exports')
    FileUtils.mkdir_p export_dir

    export_filename = "#{DateTime.now.strftime("%F_%H%M%S")}_depositor_export.csv"
    export_path = File.join(export_dir, export_filename)
    File.open(export_path, 'w'){|file| file.write(attributes.join(',') + "\n")}
    files_array = GenericFile.all.map{|file| file}
    files_array.each_slice(100){ |slice|
      slice.each do |file|
        email = file.depositor
        name = User.find_by(email: email).name rescue 'unknown'
        filename = !file.filename.blank? ? file.filename : file.label
        file_id = file.id
        collections = file.collections
        if collections.map.respond_to?('map')
          datasets = collections.map{ |c| c.title }.join("||")
          dataset_ids = collections.map{ |c| c.id }.join("||")
        end
        row = [email, name, filename, file_id, datasets || "", dataset_ids || ""]
        File.open(export_path, 'a'){|file| file.write(row.join(',') + "\n")}
      end
      GC.start
    }
    export = Export.create(user_id: self.current_user.id, filename: export_filename)
    MetadataExportMailer.notification_email(current_user, export.download_id, base_path).deliver_later
  end
end
