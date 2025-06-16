# frozen_string_literal: true

require 'rails_helper'

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
end
