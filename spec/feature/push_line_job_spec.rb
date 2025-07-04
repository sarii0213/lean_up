# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PushLineJob, type: :job do
  let(:user_without_line) { create(:user, provider: nil, uid: nil, line_notify: false) }
  let(:user_with_line_notify_on) { create(:user, provider: 'line', uid: '1234567890', line_notify: true) }
  let(:user_with_line_notify_off) { create(:user, provider: 'line', uid: '1234567891', line_notify: false) }

  let(:mock_client) { instance_double(Line::Bot::V2::MessagingApi::ApiClient) }

  before do
    allow(Line::Bot::V2::MessagingApi::ApiClient).to receive(:new).and_return(mock_client)
    allow(mock_client).to receive(:push_message).and_return(true)
  end

  context 'LINE未連携のユーザの場合' do
    let!(:user) { user_without_line }

    before do
      create(:objective, :image, user:)
      create(:objective, :verbal, user:)
    end

    it 'ビジョンボードの内容は配信されない' do
      described_class.perform_now
      expect(mock_client).not_to have_received(:push_message)
    end
  end

  context 'LINE連携済みだが通知許可がOFFの場合' do
    let!(:user) { user_with_line_notify_off }

    before do
      create(:objective, :image, user:)
      create(:objective, :verbal, user:)
    end

    it 'ビジョンボードの内容は配信されない' do
      described_class.perform_now
      expect(mock_client).not_to have_received(:push_message)
    end
  end

  context 'LINE連携済みで通知許可がONの場合' do
    let!(:user) { user_with_line_notify_on }

    before do
      create(:objective, :image, user:)
      create(:objective, :verbal, user:)
    end

    # rubocop:disable RSpec/ExampleLength
    it 'ビジョンボードの内容が1件だけ配信される' do
      described_class.perform_now
      expect(mock_client).to have_received(:push_message).with(
        push_message_request: have_attributes(
          to: user.uid,
          messages: satisfy do |messages|
            messages.all? do |m|
              m.is_a?(Line::Bot::V2::MessagingApi::TextMessage) || m.is_a?(Line::Bot::V2::MessagingApi::ImageMessage)
            end
          end
        )
      )
    end
    # rubocop:enable RSpec/ExampleLength
  end

  context 'テスト配信の場合' do
    let!(:user) { user_with_line_notify_off }

    it 'テストメッセージが配信される' do
      test_message = Line::Bot::V2::MessagingApi::TextMessage.new(text: 'test message')
      described_class.perform_now(:test, current_user: user)
      expect(mock_client).to have_received(:push_message).with(
        push_message_request: have_attributes(to: user.uid, messages: [test_message])
      )
    end
  end
end
