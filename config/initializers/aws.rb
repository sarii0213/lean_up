require 'aws-sdk'

if Rails.env.production?
  Aws.config.update({ credentials: Aws::ECSCredentials.new })
end
