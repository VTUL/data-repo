namespace :datarepo do
  desc 'Cleanup duplicate item records'
  task item_cleanup: :environment do
    File.open(File.join(Rails.root, 'tmp', 'item_ids.txt')).each do |item_id|
      item = GenericFile.find(item_id.gsub(/\n/, ""))
      item.destroy
    end
  end
end
