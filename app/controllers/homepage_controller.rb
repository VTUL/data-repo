class HomepageController < ApplicationController
  include Sufia::HomepageController

  def index
    super

    @featured_work = ContentBlock.find_or_create_by(name: ContentBlock::WORK)

    @images = Pathname.glob(Rails.root.join('app/assets/images/carousel/*.[Jj][Pp][Gg]')).shuffle[0..3]
    @images.map! { |img| img.relative_path_from(Rails.root.join('app/assets/images')).to_s }
  end
end
