# frozen_string_literal: true

require 'rails_helper'
require Rails.root.join('app/subscribers/api_error_subscriber')

RSpec.describe 'LINEログイン機能', type: :feature do
  let(:line_uid) { '1234567890' }
  let(:line_email) { 'line_user@example.com' }
  let(:line_name) { 'line_user' }

  before do
    # /auth/line -> /auth/line/callback への即時リダイレクト設定
    OmniAuth.config.test_mode = true
    # /auth/line/callback へのリダイレクト時に渡されるデータ
    OmniAuth.config.mock_auth[:line] = OmniAuth::AuthHash.new({
                                                                provider: 'line',
                                                                uid: line_uid,
                                                                info: {
                                                                  name: line_name,
                                                                  email: line_email
                                                                },
                                                                credentials: {
                                                                  token: '1234qwerty'
                                                                }
                                                              })

    Rails.application.env_config['devise.mapping'] = Devise.mappings[:user]
    Rails.application.env_config['omniauth.auth'] = OmniAuth.config.mock_auth[:line]
  end

  after do
    OmniAuth.config.mock_auth[:line] = nil
  end

  context '既存ユーザーがLINE未連携でログイン中の場合' do
    let!(:user) { create(:user, provider: nil, uid: nil) }

    before do
      login_as user
      visit user_setting_path
      click_button 'LINEと連携する'
    end

    it 'LINE連携時に、LINEに登録されたemailに更新され、LINE配信も許可に設定される' do
      user.reload
      expect(user.provider).to eq('line')
      expect(user.uid).to eq(line_uid)
      expect(user.email).to eq(line_email)
      expect(user.line_notify).to be(true)
    end
  end

  context '未サインアップでLINEログインにてアカウント作成する場合' do
    before do
      visit signup_path
      click_button 'LINEでログイン'
    end

    let(:created_user) { User.last }

    it 'LINE情報でアカウントが作成され、LINE配信が許可される' do
      expect(created_user.uid).to eq(line_uid)
      expect(created_user.provider).to eq('line')
      expect(created_user.email).to eq(line_email)
      expect(created_user.username).to eq(line_name)
      expect(created_user.line_notify).to be(true)
    end
  end

  context 'LINE連携済みのユーザーがLINEログインする場合' do
    let!(:user) do
      create(:user, provider: 'line', uid: line_uid, email: line_email, username: 'test_user', password: 'password')
    end

    before do
      visit login_path
      click_button 'LINEでログイン'
    end

    it 'LINEログイン時にusername, passwordはLINEのユーザ情報で上書きされない' do
      user.reload
      expect(user.username).to eq('test_user')
      expect(user.valid_password?('password')).to be(true)
    end
  end

  context '認証・認可のAPIリクエストが失敗した場合' do
    # strategies/line.rbの#request_phase, #build_access_token, #verify_id_tokenの例外処理をテスト
    before do
      # ApiErrorSubscriberのモックを作成
      @subscriber = double('ApiErrorSubscriber')
      allow(@subscriber).to receive(:report)
      
      # Rails.errorのsubscribersを一時的に置き換え
      @original_subs = Rails.error.instance_variable_get(:@subscribers)
      Rails.error.instance_variable_set(:@subscribers, [@subscriber])
    end

    after do
      # 元のsubscribersを復元
      Rails.error.instance_variable_set(:@subscribers, @original_subs)
    end

    context '認証コード取得のAPIリクエストが失敗した場合' do
      before do
        # line strategy mock (request_phaseで例外を発生させる)
        allow_any_instance_of(Strategies::Line).to receive(:request_phase)
          .and_raise(StandardError.new('Authorization request failed'))
      end

      xit '認可コード取得エラーがApiErrorSubscriberに報告される' do
        visit user_line_omniauth_authorize_url

        expect(@subscriber).to have_received(:report).with(
          an_instance_of(StandardError),
          hash_including(handled: false, context: hash_including(action: 'auth code request'))
        )
      end
    end

    context 'アクセストークン取得のAPIリクエストが失敗した場合' do
      
    end

    context 'IDトークン検証のAPIリクエストが失敗した場合' do
      
    end
  end
end
