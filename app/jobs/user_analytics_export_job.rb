class UserAnalyticsExportJob
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
    attributes = %w{uid email display_name sign_in_count current_sign_in_at last_sign_in_at current_sign_in_ip last_sign_in_ip created_at updated_at }

    export_dir = File.join(Rails.root.to_s, 'tmp', 'exports')
    FileUtils.mkdir_p export_dir

    export_filename = "#{DateTime.now.strftime("%F_%H%M%S")}_user_analytics_export.csv"
    export_path = File.join(export_dir, export_filename)
    File.open(export_path, 'w'){|file| file.write(attributes.join(',') + "\n")}
    User.all.each do |user|
      row = [
        user.uid, 
        user.email, 
        user.display_name || "", 
        user.sign_in_count || 0, 
        user.current_sign_in_at || "", 
        user.last_sign_in_at || "", 
        user.current_sign_in_ip || "",
        user.last_sign_in_ip || "",
        user.created_at,
        user.updated_at
      ]
      File.open(export_path, 'a'){|file| file.write(row.join(',') + "\n")}
    end
    export = Export.create(user_id: self.current_user.id, filename: export_filename)
    MetadataExportMailer.notification_email(current_user, export.download_id, base_path).deliver_later
  end
end
