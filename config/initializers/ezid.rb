Ezid::Client.configure do |config|
  #config.host = "https://ez.datacite.org/"
  #config.port = 443
  #config.use_ssl = true
  #config.timeout = 600
  # VT libraries' unique DOI prefix with EZID
  config.host = Rails.application.secrets['doi']['host'] || 'https://ez.datacite.org/'
  config.default_shoulder = Rails.application.secrets['doi']['default_shoulder']
  config.user = Rails.application.secrets['doi']['user']
  config.password = Rails.application.secrets['doi']['password']
  config.identifier.defaults[:status] = "reserved"
  config.identifier.defaults[:profile] = "datacite"
end
