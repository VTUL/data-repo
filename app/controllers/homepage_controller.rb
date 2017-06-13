class HomepageController < ApplicationController
  include Sufia::HomepageController
  helper_method :route_exists

  def index
    super

    @featured_work = ContentBlock.find_or_create_by(name: ContentBlock::WORK)

    images = Pathname.glob(Rails.root.join('app/assets/images/carousel/*.[Jj][Pp][Gg]')) 
    if !images.empty?
      @banner_image = images.shuffle[0..(images.length - 1)].first.relative_path_from(Rails.root.join('app/assets/images')).to_s
    else
      @banner_image = ""
    end
  end

  def route_exists route
    begin
      recognized = Rails.application.routes.recognize_path(route)
    rescue
      recognized = false
    end
    return recognized
  end
end
