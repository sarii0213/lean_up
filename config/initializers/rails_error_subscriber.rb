
Rails.application.config.after_initialize do
  Rails.error.subscribe(ApiErrorSubscriber.new)
end
