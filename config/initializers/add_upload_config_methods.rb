module Sufia
  class Configuration
    attr_writer :store_path
    def store_path
      @store_path ||= ->() { Rails.root + 'tmp' + 'uploads' }
    end

    attr_writer :cache_path
    def cache_path
      @cache_path ||= ->() { Rails.root + 'tmp' + 'uploads' + 'cache' }
    end
  end
end
