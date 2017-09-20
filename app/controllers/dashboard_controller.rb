class DashboardController < ApplicationController
  include Sufia::DashboardControllerBehavior
  require 'vtul/csv_generator'

  def admin_metadata_download
    time_stamp = DateTime.now.strftime('%Q')
    csv_generator = CsvGenerator.new(time_stamp)
    csv_generator.make_archive
    csv_generator.generate_all('Collection')
    csv_generator.generate_all('GenericFile')
    zip_file = csv_generator.zip
    while !File.file? zip_file
      sleep(0.1)
    end
    send_file zip_file
  end

end
