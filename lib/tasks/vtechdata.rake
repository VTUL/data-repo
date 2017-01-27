require 'rspec/core/rake_task'
require 'active_fedora/rake_support'

namespace :vtechdata do
  desc 'Run specs only'
  RSpec::Core::RakeTask.new(:rspec) do |task|
    Rake::Task['tmp:clear'].invoke
    task.rspec_opts = ['--color']
    Rake::Task['tmp:clear'].invoke
  end

  desc 'Run specs on CI'
  task ci: :environment do |task|
    with_test_server do
      Rake::Task['vtechdata:rspec'].invoke
    end
  end
end
