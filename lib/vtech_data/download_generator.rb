class DownloadGenerator
  require 'fileutils'

  attr_accessor :model_name, :my_class, :timestamp, :archive_name, :archive_full_path

  def initialize(time_stamp)
    @timestamp = time_stamp
    @archive_name = "#{timestamp}_vtechdata_export"
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

  def generate_all_metadata class_name
    @model_name = class_name
    @my_class = class_name.constantize
    items = get_all_items_for_model(my_class)
    file_path = File.join(self.class.csv_dir, archive_name, "#{timestamp}_#{model_name.downcase}.csv")
    write_csv(file_path, my_class, items, true)
  end

  def generate_dataset_download dataset_id, admin_download
    collection_file_path = File.join(self.class.csv_dir, archive_name, "dataset_#{dataset_id}.csv")
    write_csv(collection_file_path, Collection, [Collection.find(dataset_id)], admin_download)
    collection_members = Collection.find(dataset_id).members
    if !collection_members.blank?
      items_file_path = File.join(self.class.csv_dir, archive_name, "dataset_#{dataset_id}_items.csv")
      write_csv(items_file_path, GenericFile, collection_members, admin_download)
      add_files(collection_members)
    end
  end

  def zip
    zip_file = "#{archive_full_path}.zip"
    Dir.chdir archive_full_path
    files_to_archive = Dir['**/*'].reject {|fn| File.directory?(fn) }

    archive = Archive::Compress.new(zip_file, :type => :zip)
    archive.compress(files_to_archive)

    return zip_file
  end

  private

    def get_all_items_for_model item_class
      item_class.all
      #query = ActiveFedora::SolrQueryBuilder.construct_query_for_rel(has_model: model_name)
      #ActiveFedora::SolrService.query(query)
    end

    def add_files items
      items.each do |generic_file|
        filename = !generic_file.filename.empty? ? generic_file.filename : generic_file.label
        item_target_path = File.join(archive_full_path, filename)
        # If a file already exists with this filename then put this one in a sub-directory named after the item id
        if File.file? item_target_path
          FileUtils::mkdir_p(File.join(archive_full_path, generic_file.id))
          item_target_path =  File.join(archive_full_path, generic_file.id, filename)
        end
        File.open(item_target_path, 'wb') { |file| file.write(generic_file.content.content) }
      end      
    end

    def write_csv file_path, item_class, records, admin_download
      CSV.open(file_path,'wb') do |csv|
        if admin_download
          headers = item_class.new.admin_csv_headers
        else
          headers = item_class.new.csv_headers
        end
        csv << headers
        records.each do |record|
          if admin_download
            values = record.admin_csv_values
          else
            values = record.csv_values
          end
          csv << values
        end
      end
    end

end

