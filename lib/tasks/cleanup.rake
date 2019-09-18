namespace :datarepo do
  desc 'Cleanup duplicate item records'
  task item_cleanup: :environment do
    table = CSV.read(File.join(Rails.root, 'tmp', 'items.csv'), headers: true)
    table.each do |line|
      puts line['title_tesim']
      puts line['id']
      puts ""
      #item = GenericFile.find(item_id.gsub(/\n/, ""))
      #item.destroy
    end
  end
end
