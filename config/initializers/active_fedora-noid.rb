require 'active_fedora/noid'

ActiveFedora::Noid.configure do |config|
  config.statefile = '/var/sufia/minter-state'

  unless Rails.application.secrets['fedora']['noid_statefile'].nil?
    config.statefile = Rails.application.secrets['fedora']['noid_statefile']
  end
end
