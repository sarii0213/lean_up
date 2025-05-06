require 'aws-sdk'

# ECS環境での実行時のみECSCredentialsを使用する
if ENV['AWS_CONTAINER_CREDENTIALS_RELATIVE_URI'].present?
  Aws.config.update({ credentials: Aws::ECSCredentials.new })
end
