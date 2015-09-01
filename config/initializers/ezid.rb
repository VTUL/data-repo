Ezid::Client.configure do |config|
  #config.host = "ezid.cdlib.org"
  #config.port = 443
  #config.use_ssl = true
  #config.timeout = 600
  # VT libraries' unique DOI prefix with EZID
  config.default_shoulder = "doi:10.5072/FK2"
  config.user = "apitest"
  config.password = "apitest"
  config.identifier.defaults[:status] = "reserved"
  config.identifier.defaults[:profile] = "datacite"
end
