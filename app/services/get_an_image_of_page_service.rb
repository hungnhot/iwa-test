# frozen_string_literal: true
require "open-uri"
require "benchmark"

class GetAnImageOfPageService < BaseService
  include SimpleCache
  attr_reader :url, :options

  def initialize url, options = {ignore_image_format: ["svg"], min_image_width: 150, min_image_height: 150}
    @url = url
    @options = options
  end

  def perform
    @image = read_cache 
    get_image if @image.blank?

    success! @image
  rescue StandardError => e
    fail! e.message, e
  end

  private
  def get_image
    images = GetImagesOfPageService.new(url, 1, options).perform
    @image = images.first
    write_cache @image
  end

  def cache_key
    @cache_key ||= "image-#{Base64.urlsafe_encode64(url)}"
  end
end
