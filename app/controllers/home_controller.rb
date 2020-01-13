class HomeController < ApplicationController
  before_action :set_default_page, only: %w(index)

  def index
    service = GetListNewsService.new params[:page]
    service.perform

    @page = params[:page].to_i
    @data = service.result || []
  end

  def article
    @url = params[:url]
    service = GetANewsService.new(@url)
    service.perform

    @data = service.result || {}
  end

  private
  def set_default_page
    params[:page] = 1 if params[:page].blank? || params[:page].to_i < 1
  end
end
