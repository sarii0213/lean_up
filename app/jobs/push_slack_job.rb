# frozen_string_literal: true

class PushSlackJob < ApplicationJob
  queue_as :default

  DEFAULT_CHANNEL = '#general'

  def perform(context)
    client = Slack::Web::Client.new
    client.chat_postMessage(
      channel: DEFAULT_CHANNEL,
      text: 'message from slack error subscriber',
      blocks: build_message_blocks(context)
    )
  end

  private

  def build_message_blocks(context)
    [
      build_header_block(context[:action]),
      build_divider_block,
      build_details_block(context.except(:action))
    ]
  end

  def build_header_block(action)
    {
      type: 'header',
      text: {
        type: 'plain_text',
        text: ":bell: #{action}"
      }
    }
  end

  def build_divider_block
    { type: 'divider' }
  end

  def build_details_block(details)
    {
      type: 'section',
      text: {
        type: 'mrkdwn',
        text: format_details(details)
      }
    }
  end

  def format_details(details)
    details.map { |key, value| "*#{key}*: #{value}" }.join("\n")
  end
end
