# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  display_body_fat       :boolean          default(TRUE)
#  email                  :string(191)      default(""), not null
#  enable_periods_feature :boolean          default(TRUE)
#  encrypted_password     :string           default(""), not null
#  goal_weight            :decimal(, )
#  height                 :decimal(, )
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  username               :string(191)      default("")
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
require 'rails_helper'

RSpec.describe User, type: :model do
  describe '#line_connected?' do
    context 'ユーザーがLINE連携済みの場合' do
      let(:user) { create(:user, provider: 'line', uid: '123') }

      it 'trueを返す' do
        expect(user.line_connected?).to be true
      end
    end

    context 'ユーザーがLINE未連携の場合' do
      let(:user) { create(:user, provider: nil, uid: nil) }

      it 'falseを返す' do
        expect(user.line_connected?).to be false
      end
    end
  end

  describe '#line_notification_allowed?' do
    context 'ユーザーがLINE連携済み＆通知ONの場合' do
      let(:user) { create(:user, provider: 'line', uid: '123', line_notify: true) }

      it 'trueを返す' do
        expect(user.line_notification_allowed?).to be true
      end
    end

    context 'ユーザーがLINE通知OFFの場合' do
      let(:user) { create(:user, provider: 'line', uid: '123', line_notify: false) }

      it 'falseを返す' do
        expect(user.line_notification_allowed?).to be false
      end
    end
  end

  describe '#on_period?' do
    let(:user) { create(:user) }
    let(:started_on) { Date.new(2025,1, 1) }
    let(:ended_on) { Date.new(2025,1, 7) }

    before do
      create(:period, user:, started_on:, ended_on:)
    end

    context '体重計測日がユーザーの生理期間中だった場合' do
      let(:date) { Date.new(2025, 1, 3) }

      it 'trueを返す' do
        expect(user.on_period?(date)).to be true
      end
    end

    context '体重計測日がユーザーの生理期間外だった場合' do
      let(:date) { Date.new(2025, 1, 10) }

      it 'falseを返す' do
        expect(user.on_period?(date)).to be false
      end
    end
  end

  describe '.from_omniauth' do
    let(:auth) do
      OmniAuth::AuthHash.new(
        provider: 'line',
        uid: '123',
        info: {
          email: 'test@example.com',
          name: 'line_user'
        }
      )
    end

    subject { described_class.from_omniauth(auth, current_user) }

    context 'ユーザー未作成の場合' do
      let(:current_user) { nil }

      it '.sign_in_or_create_user_from_lineに委譲する' do
        expect(described_class).to receive(:sign_in_or_create_user_from_line).with(auth).and_return(:new_user)
        subject
      end
    end

    context 'ユーザーがLINE連携済みの場合' do
      let(:current_user) { build(:user) }

      before { allow(current_user).to receive(:line_connected?).and_return(true) }

      it '.sign_in_or_create_user_from_lineに委譲する' do
        expect(described_class).to receive(:sign_in_or_create_user_from_line).with(auth).and_return(:existing_user)
        subject
      end
    end

    context 'ユーザーがLINE未連携の場合' do
      let(:current_user) { build(:user) }

      before { allow(current_user).to receive(:line_connected?).and_return(false) }

      it '.link_line_accountに委譲する' do
        expect(described_class).to receive(:link_line_account).with(auth, current_user).and_return(:updated_user)
        subject
      end
    end
  end

  describe '.link_line_account' do
    let(:auth) do
      OmniAuth::AuthHash.new(
        provider: 'line',
        uid: '123',
        info: {
          email: 'test@example.com',
          name: 'line_user'
        }
      )
    end
    let(:current_user) do
      create(:user,
        provider: nil,
        uid: nil,
        email: 'before@example.com',
        line_notify: false
      )
    end

    context 'auth情報を組み込んでユーザーの更新ができた場合' do
      it '更新したユーザーを返す' do
        result = described_class.link_line_account(auth, current_user)
        expect(result).to eq(current_user)

        current_user.reload
        aggregate_failures do
          expect(current_user.provider).to eq('line')
          expect(current_user.uid).to eq('123')
          expect(current_user.email).to eq('test@example.com')
          expect(current_user.line_notify).to be true
        end
      end
    end

    context 'auth情報を組み込んでユーザーの更新ができなかった場合' do
      # 更新失敗理由：auth情報のuid, emailが他ユーザーと重複
      it 'nilを返す' do
        allow(current_user).to receive(:update).and_return(false)
        expect(described_class.link_line_account(auth, current_user)).to be_nil
      end
    end

  end

  describe '.sign_in_or_create_user_from_line' do
    let(:auth) do
      OmniAuth::AuthHash.new(
        provider: 'line',
        uid: '123',
        info: {
          email: 'test@example.com',
          name: 'line_user'
        }
      )
    end

    context 'ユーザーがLINE連携済みの場合' do
      let!(:existing_user) do
        create(:user,
          provider: 'line',
          uid: '123',
          email: 'test@example.com'
        )
      end

      it 'LINE連携済みユーザーを返す' do
        user = described_class.sign_in_or_create_user_from_line(auth)
        expect(user).to eq(existing_user)
      end
    end

    context 'ユーザー未作成の場合' do
      it 'auth情報をもとに新規ユーザーを作成する' do
        expect { @user = described_class.sign_in_or_create_user_from_line(auth) }.to change(User, :count).by(1)
        @user.reload

        aggregate_failures do
          expect(@user.username).to eq('line_user')
          expect(@user.email).to eq('test@example.com')
          expect(@user.provider).to eq('line')
          expect(@user.uid).to eq('123')
          expect(@user.line_notify).to be true
          expect(@user.encrypted_password).to be_present
        end
      end
    end
  end
end
