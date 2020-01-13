# frozen_string_literal: true

class BaseService
  attr_reader :result, :message, :debug_info

  def success?
    !!@success
  end

  def failure?
    !success?
  end

  private

  def success! result
    @success = true
    @result = result
  end

  def fail! message, debug_info = {}
    @success = false
    @message = message
    @debug_info = debug_info
    Rails.logger.error "#{self.class.name} error: #{@message}"
    # puts "#{self.class.name} error: #{@message}"
  end
end
