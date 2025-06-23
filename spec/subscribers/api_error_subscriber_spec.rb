# frozen_string_literal: true

require 'rails_helper'
require Rails.root.join('app/subscribers/api_error_subscriber')

RSpec.describe ApiErrorSubscriber, type: :feature do
  let(:error) { StandardError.new('API request failed') }
  let(:slack_client) { instance_double(Slack::Web::Client) }

  before do
    allow(Slack::Web::Client).to receive(:new).and_return(slack_client)
    allow(slack_client).to receive(:chat_postMessage)
  end

  describe '#report' do
    context 'LINEログイン時のエラーを受け取った場合' do
      let(:context) do
        {
          action: '[LINE login] ID token verification & get user info',
          has_id_token: access_token['id_token'].present?
        }
      end
      let(:access_token) { { id_token: '11111' } }

      it 'エラー内容をSlackに通知する' do
        Rails.error.report(error, context:)

        expect(slack_client).to have_received(:chat_postMessage).with(
          hash_including(blocks: include('[LINE login]'))
        )
      end
    end

    context 'LINE配信時のエラーを受け取った場合' do
      let(:context) do
        {
          action: '[LINE delivery] push message',
          user_id: user.id,
          objective_id:  objective.id
        }
      end
      let(:user) { create(:user, provider: 'line', uid: '1234567') }
      let(:objective) { create(:objective, user:) }

      it 'エラー内容をSlackに通知する' do
        Rails.error.report(error, context:)

        expect(slack_client).to have_received(:chat_postMessage).with(
          hash_including(blocks: include('[LINE delivery]'))
        )
      end
    end
  end
end
