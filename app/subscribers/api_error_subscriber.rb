# frozen_string_literal: true

class ApiErrorSubscriber
  def report(_error, context:, **)
    client = Slack::Web::Client.new
    client.chat_postMessage(
      channel: '#general',
      text: 'LINE API request error',
      blocks: build_message(context)
    )
  end

  private

  # rubocop:disable Metrics/MethodLength
  def build_message(context)
    action = context[:action]
    details = context.except(:action).map { |k, v| "*#{k}*: #{v}" }.join('\n ')

    <<-"BLOCKS"
    [
      {
        "type": "header",
        "text": {
          "type": "plain_text",
          "text": ":bell: #{action}"
        }
      },
      {
        "type": "divider"
      },
      {
        "type": "section",
        "text": {
          "type": "mrkdwn",
          "text": "#{details}"
        }
      }
    ]
    BLOCKS
  end
  # rubocop:enable Metrics/MethodLength
end
