require 'omniauth-oauth2'

module Strategies
  class Line < OmniAuth::Strategies::OAuth2

    # request phase -----------------------------------------------------
    
    # IDトークン, プロフィール情報, 表示名, プロフィール画像の取得権限を含める
    option :scope, 'openid profile email'

    # optionを渡す先
    option :client_options, {
      site: 'https://api.line.me',
      authorize_url: 'https://access.line.me/oauth2/v2.1/authorize',
      token_url: 'https://api.line.me/oauth2/v2.1/token'
    }

    # callback phase ---------------------------------------------------
    # 取得したデータ(LINEユーザーID)からuid(=unique to the provider)をセット
    uid { raw_info['sub'] }

    # 取得したデータからinfo(= a hash of information about the user)をセット
    info do
      {
        name: raw_info['name'],
        email: raw_info['email']
      }
    end

    def raw_info
      @raw_info ||= verify_id_token
    end

    private

    # ID Tokenに必須のnonceをパラメータに追加
    def authorize_params
      super.tap do |params|
        params[:nonce] = SecureRandom.uuid
        session['omniauth.nonce'] = params[:nonce]
      end
    end

    # omniauthのcallback_urlはquery stringがついてしまい、LINE側に登録したcallback URLとの不一致エラーになるそうなのでoverride
    # 参考： https://zenn.dev/hid3/articles/40ab3d1060f013#%E3%82%B3%E3%83%BC%E3%83%AB%E3%83%90%E3%83%83%E3%82%AF%E3%83%95%E3%82%A7%E3%83%BC%E3%82%BA
    # callback_url: https://github.com/omniauth/omniauth/blob/0bcfd5b25bf946422cd4d9c40c4f514121ac04d6/lib/omniauth/strategy.rb#L498
    def callback_url
      full_host + callback_path
    end

    # ID token 検証 & ユーザ情報取得のAPIリクエスト
    def verify_id_token
      @id_token_payload ||= begin
        client.request(:post, 'https://api.line.me/oauth2/v2.1/verify', 
          {
            body: {
              id_token: access_token['id_token'],
              client_id: options.client_id,
              nonce: session.delete('omniauth.nonce')
            }
          }
        ).parsed
      rescue => e
        Rails.error.report(e, context: { 
          action: 'LINE ID token verification & get user info',
          client_id: options.client_id,
          has_id_token: access_token['id_token'].present?
        })
        raise
      end
    
      @id_token_payload
    end
  end
end
