namespace :datarepo do
  desc 'Cleanup duplicate item records'
  task item_cleanup: :environment do
    table = CSV.read(File.join(Rails.root, 'tmp', 'items.csv'), headers: true)
    table.each do |line|
      puts "Deleting Item: #{line['id']}, Title: #{line['title_tesim']}."
      begin
        item = GenericFile.find(line['id'].gsub(/\n/, ""))
        item.destroy
      rescue
        puts "Record not found: #{line['id']}"
      end
    end
  end
end
