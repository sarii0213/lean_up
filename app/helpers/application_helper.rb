# frozen_string_literal: true

module ApplicationHelper
  def turbo_stream_flash
    turbo_stream.append 'flashes', partial: 'flash'
  end
end
