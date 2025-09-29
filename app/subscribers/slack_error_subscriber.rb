# frozen_string_literal: true

class SlackErrorSubscriber
  def report(_error, context:, **)
    if Rails.env.production?
      PushSlackJob.perform_later(context)
    else
      log_error(context)
    end
  end

  private

  def log_error(context)
    Rails.logger.info("SlackErrorSubscriber has subscribed to this error:\ncontext: #{context}")
  end
end
