# frozen_string_literal: true

require 'line/bot'

class PushLineJob < ApplicationJob
  queue_as :default

  # rubocop:disable Metrics/MethodLength
  def perform(*_args)
    users = User.where.not(uid: nil).where(line_notify: true).includes(:objectives)
    users.each do |user|
      objective = user.objectives.sample
      next if objective.blank?

      message = build_message(objective)
      request = Line::Bot::V2::MessagingApi::PushMessageRequest.new(to: user.uid, messages: [message])
      begin
        client.push_message(push_message_request: request)
      rescue StandardError => e
        report_error(e, user, objective)
      end
    end
  end
  # rubocop:enable Metrics/MethodLength

  private

  def build_message(objective)
    case objective.objective_type
    when 'image'
      image = objective.images.sample
      original_content_url = Rails.application.routes.url_helpers.url_for(image)
      preview_image_url = Rails.application.routes.url_helpers.url_for(image.variant(:large))
      Line::Bot::V2::MessagingApi::ImageMessage.new(original_content_url:, preview_image_url:)
    when 'verbal'
      text = objective.verbal
      Line::Bot::V2::MessagingApi::TextMessage.new(text:)
    end
  end

  def client
    Line::Bot::V2::MessagingApi::ApiClient.new(
      channel_access_token: ENV.fetch('LINE_BOT_CHANNEL_ACCESS_TOKEN', nil)
    )
  end

  def report_error(error, user, objective)
    Rails.error.report(error, context:
      {
        action: '[LINE delivery] push message',
        user_id: user.id,
        objective_id: objective.id
      })
  end
end
