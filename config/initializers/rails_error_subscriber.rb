Rails.application.config.after_initialize do
  Rails.error.subscribe(SlackErrorSubscriber.new)
end
