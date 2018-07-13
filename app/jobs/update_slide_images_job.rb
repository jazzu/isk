# frozen_string_literal: true

class UpdateSlideImagesJob < ActiveJob::Base
  queue_as :default

  def perform(slide)
    slide.generate_images
  end
end
