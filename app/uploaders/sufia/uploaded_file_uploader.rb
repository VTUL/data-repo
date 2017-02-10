module Sufia
  class UploadedFileUploader < CarrierWave::Uploader::Base
    # Override the directory where uploaded files will be stored.
    # This is a sensible default for uploaders that are meant to be mounted:
    def store_dir
      sufia_store_path + "#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
    end

    def cache_dir
      sufia_cache_path + "#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
    end

    private

      def sufia_store_path
        Sufia.config.store_path.call
      end

      def sufia_cache_path
        Sufia.config.cache_path.call
      end
  end
end
