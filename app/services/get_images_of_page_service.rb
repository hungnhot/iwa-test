# frozen_string_literal: true
require "open-uri"

class GetImagesOfPageService < BaseService
  attr_reader :url, :max_num, :options, :images, :failed_images

  def initialize url, max_num = 1, options = {ignore_image_format: ["svg"], min_image_width: 150, min_image_height: 150}
    @url = url
    @max_num = max_num
    @options = options
    @images = []
    @failed_images = []
  end

  def perform
    get_images

    success! @images
  rescue StandardError => e
    fail! e.message, e
  end

  private
  def get_images
    use_readability
    return unless images.blank?
    use_nokogiri
  end

  def use_readability
    body = open(url).read
    r_options = {tags: %w[div p img a], attributes: %w[src href], remove_empty_nodes: false}.merge(options)
    rbody = Readability::Document.new(body, r_options)
    images = rbody.images.map { |e| process_image_url(e) }
  rescue StandardError => e
    fail! e.message, e
  end

  def use_nokogiri
    doc = Nokogiri::HTML(open(url))
    doc.css("div img", "p img").each do |img|
      next unless img["src"]
      process_item img
      break if images.length == max_num
    end
  rescue StandardError => e
    fail! e.message, e
  end

  def process_item element
    image_url = process_image_url(element["src"].to_s)
    return if failed_images.include?(image_url)

    height  = element["height"].nil? ? 0 : element["height"].to_i
    width   = element["width"].nil?  ? 0 : element["width"].to_i
    image = {width: width, height: height}

    if image_url =~ /\Ahttps?:\/\//i && (height.zero? || width.zero?)
      image = get_image_size(image_url)
    end

    image[:format] = File.extname(image_url).gsub(".", "").split("?").first.to_s

    if image_meets_criteria?(image)
      images << image_url
    else
      failed_images << image_url
    end
  rescue StandardError => e
    fail! e.message, e
  end

  def get_image_size image_url
    w, h = FastImage.size(image_url)

    {width: w || 0, height: h || 0}
  rescue StandardError => e
    fail! "Image error: #{e.message}", e
    nil
  end

  def process_image_url image_url
    return image_url if image_url =~ /\Ahttps?:\/\//i || image_url =~ /\Adata:/i
    return url + "/" + image_url unless image_url.start_with?("/")

    myUri = url =~ /\Ahttps?:\/\//i ? URI(url) : URI("https://#{url}")
    myUri.scheme + "://" + myUri.host + image_url
  end

  def image_meets_criteria? image
    return false if options[:ignore_image_format].include?(image[:format].downcase)
    image[:width] >= (options[:min_image_width] || 0) && image[:height] >= (options[:min_image_height] || 0)
  end
end
