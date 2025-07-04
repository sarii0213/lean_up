# frozen_string_literal: true

require 'line/bot'

class PushLineJob < ApplicationJob
  queue_as :default

  def perform(mode: :daily, current_user: nil)
    if mode == :test
      send_test_message(current_user)
    else
      send_daily_objectives
    end
  end

  private

  def send_test_message(user)
    message = Line::Bot::V2::MessagingApi::TextMessage.new(text: 'test message')
    send_message_to_user(user, message, action: '[LINE delivery test] push message')
  end

  def send_daily_objectives
    users = User.where.not(uid: nil).where(line_notify: true).includes(:objectives)
    users.each do |user|
      objective = user.objectives.sample
      next if objective.blank?

      message = build_message(objective)
      send_message_to_user(user, message, action: '[LINE delivery] push message', objective: objective)
    end
  end

  def send_message_to_user(user, message, action:, objective: nil)
    request = Line::Bot::V2::MessagingApi::PushMessageRequest.new(to: user.uid, messages: [message])
    begin
      client.push_message(push_message_request: request)
    rescue StandardError => e
      context = { action: action, user_id: user.id }
      context[:objective_id] = objective.id if objective
      Rails.error.report(e, context: context)
    end
  end

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
end
