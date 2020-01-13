# frozen_string_literal: true
require "open-uri"

class GetListNewsService < BaseService
  attr_reader :page
  URL = "https://news.ycombinator.com/best"
  URL_PER_PAGE = 30
  PER_PAGE = 3

  def initialize page = 1
    @page = page.to_i
    @data = []
  end

  def perform
    parse_content

    success! @data
  rescue StandardError => e
    fail! e.message, e
  end

  private
  def url_with_page
    @url ||= page > 1 ? "#{URL}?p=#{get_url_page}" : URL
  end

  def parse_content
    num_element = URL_PER_PAGE / PER_PAGE
    arr_news_index = page > num_element ? (page % num_element) - 1 : page - 1
    doc = Nokogiri::HTML(open(url_with_page))
    doc.css("table.itemlist tr.athing").each_with_index do |tr, index|
      process_item tr if arr_news[arr_news_index].include?(index)
    end
  end

  def arr_news
    pos = URL_PER_PAGE * get_url_page
    arr = [*pos-URL_PER_PAGE .. pos-1].map { |i| i % URL_PER_PAGE }
    arr.each_slice(PER_PAGE).to_a
  end

  def get_url_page
    return 1 if PER_PAGE * page <= URL_PER_PAGE
    ((PER_PAGE * page) / URL_PER_PAGE) + 1
  end

  def process_item tr
    td = tr.css(".title").last
    link = td.css(".storylink").first
    url = link.attributes["href"].value
    image = get_image url

    @data << {
      text: link.content&.strip_all_spaces,
      sitebit: td.css(".sitebit").first&.text&.strip_all_spaces,
      url: url,
      image: image,
      subtext: get_subtext(tr)
    }
  rescue StandardError => e
    fail! e.message, e
  end

  def get_image url
    image = GetAnImageOfPageService.new(url).perform
  rescue StandardError => e
    fail! e.message, e
  end

  def get_subtext tr
    tr_next = tr.next_element
    tr_next.css(".subtext").first.content.strip_all_spaces
  end
end
