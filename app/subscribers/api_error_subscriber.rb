class ApiErrorSubscriber
  def report(error, handled:, severity:, context:, source:)
    Rails.logger.error("[rails_error] #{context}") # todo: slack通知にする
  end
end
