module CollectionHelper
  def deletable_dataset(id)
    collection = Collection.find(id)
    collection[:identifier].each do |id|
      if /\A#{Ezid::Client.config.default_shoulder}/ =~ id
        return false
      end
    end
    return true 
  end
end
