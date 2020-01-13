# frozen_string_literal: true
require "open-uri"

class GetANewsService < BaseService
  include SimpleCache
  attr_reader :url

  def initialize url
    @url = url
    @data = {}
  end

  def perform
    @data = read_cache
    parse_content if @data.blank?

    success! @data
  rescue StandardError => e
    fail! e.message, e
  end

  private
  def parse_content
    body = open(url).read
    content = Readability::Document.new(body).content
    @data = {
      image: get_image,
      content: content
    }

    write_cache @data
  end

  def get_image
    image = GetAnImageOfPageService.new(url).perform
   rescue StandardError => e
    fail! e.message, e
  end

  def get_subtext tr
    tr_next = tr.next_element
    tr_next.css(".subtext").first.content.strip_all_spaces
  end

  def cache_key
    @cache_key ||= "news-#{Base64.urlsafe_encode64(url)}"
  end
end
