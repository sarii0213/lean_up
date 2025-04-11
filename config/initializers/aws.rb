if ENV['AWS_ACCESS_KEY_ID'].blank? && Rails.env.production?
  Aws.config.update({ credentials: Aws::ECSCredentials.new })
end
