class CsvGenerator
  require 'fileutils'
  attr_accessor :model_name, :my_class, :timestamp, :archive_name, :archive_full_path

  def initialize(time_stamp)
    @timestamp = time_stamp
    @archive_name = "#{timestamp}_admin_metadata"
    @archive_full_path = File.join(self.class.csv_dir, archive_name)
  end

  def self.csv_dir
    File.join(Rails.root, 'tmp', 'downloads')
  end

  def self.clear_csv_dir
    begin
      FileUtils.rm_rf(Dir.glob("#{csv_dir}/*"))
    rescue
      puts 'error clearing csv dir'
    end
  end

  def make_archive
    self.class.clear_csv_dir
    FileUtils::mkdir_p(archive_full_path)
  end

  def generate_all class_name
    @model_name = class_name
    @my_class = class_name.constantize
    headers = my_class.new.csv_headers
    items = get_items
    CSV.open(File.join(self.class.csv_dir, archive_name, "#{timestamp}_#{model_name.downcase}.csv"),'wb') do |csv|
      csv << headers
      items.each do |item|
        record = my_class.find(item["id"])
        csv << record.csv_values
      end
    end    
  end

  def zip
    zip_file = "#{archive_full_path}.zip"
    files_to_zip = Dir.entries(archive_full_path).reject {|f| File.directory? f}
    Zip::File.open(zip_file, Zip::File::CREATE) do |zipfile|
      files_to_zip.each do |f|
        zipfile.add(f, File.join(archive_full_path, f))
      end
    end	
    return zip_file
  end

  def get_items
    query = ActiveFedora::SolrQueryBuilder.construct_query_for_rel(has_model: model_name)
    ActiveFedora::SolrService.query(query)
  end

end
