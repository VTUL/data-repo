require 'rspec/core/rake_task'
require 'active_fedora/rake_support'

namespace :vtechdata do
  desc 'Run specs only'
  RSpec::Core::RakeTask.new(:rspec) do |task|
    task.rspec_opts = ['--color']
  end

  desc 'Run specs on CI'
  task ci: :environment do |task|
    with_test_server do
      Rake::Task['vtechdata:rspec'].invoke
    end
  end
end
