
class PublishedValidator

  def run published_csv

    data = CSV.read(published_csv, headers: true)

    headers = ["dataset_id","dataset_title","doi","date_published", "item_id", "item_title", "last_modified_date", "modified_after_publish?"] 
    CSV.open("tmp/#{Time.now.to_i}_published_validation_output.csv", "wb") do |csv|
      csv << headers

      data.each do |dataset|
        dataset_publish_date = dataset['Date Published'].to_s
        if is_valid?(dataset['Dataset Title']) && is_valid?(dataset['DOI']) && is_valid_date?(dataset_publish_date)
          time_obj = Time.new(dataset_publish_date[0,4],dataset_publish_date[4,2],dataset_publish_date[6,2])
          published_timestamp = time_obj.to_i
          datasets = nil
          datasets = Collection.where(identifier: dataset['DOI'])
          datasets.each do |dataset_record|
            if dataset_record.identifier.first == dataset['DOI']
              dataset_record.member_ids.each do |item_id|
                row = []
                item = GenericFile.find(item_id)
                last_modified = 0
                item.events.each do |event|
                  last_modified = event[:timestamp].to_i if event[:timestamp].to_i > last_modified
                end
                last_modified_formatted = Time.at(last_modified).to_datetime.strftime("%Y%m%d")
                modified_after_publish = last_modified >= published_timestamp ? true : false
                [dataset_record.id, dataset_record.title, dataset_record.identifier.first, dataset_publish_date, item.id, item.title.first, last_modified_formatted, modified_after_publish].each do |value|
                  row << value
                end
                csv << row
              end 
            end
          end
        end
      end
    end
  end

  def is_valid? value
    !value.blank? && value != "NA"
  end

  def is_valid_date? date
    return false if !is_valid? date
    dateObj = nil
    begin
      dateObj = Date.parse("#{date[0,4]}-#{date[4,2]}-#{date[6,2]}")
    rescue
      return false
    end
    return true
  end
end
