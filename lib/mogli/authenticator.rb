require "cgi"
require 'mogli/client'

module Mogli
  class Authenticator
    attr_reader :client_id, :secret, :callback_url

    def initialize(client_id,secret,callback_url)
      @client_id = client_id
      @secret = secret
      @callback_url = callback_url
    end

    def authorize_url(options = {})
      auth_type_url = options.delete(:type) == "dialog" ? "www.facebook.com/dialog/oauth" : "graph.facebook.com/oauth/authorize"
      options_part = "&" + options.map {|k,v| "#{k}=#{v.kind_of?(Array) ? v.join(',') : v}" }.join('&') unless options.empty?
      "https://#{auth_type_url}?client_id=#{client_id}&redirect_uri=#{CGI.escape(callback_url)}#{options_part}"
    end
    
    def access_token_url(code)
      "https://graph.facebook.com/oauth/access_token?client_id=#{client_id}&redirect_uri=#{CGI.escape(callback_url)}&client_secret=#{secret}&code=#{CGI.escape(code)}"
    end

    def get_access_token_for_session_key(session_keys)
      keystr = session_keys.is_a?(Array) ?
                 session_keys.join(',') : session_keys
      client = Mogli::Client.new
      client.post("oauth/exchange_sessions", nil,
                  {:type => 'client_cred',
                   :client_id => client_id,
                   :client_secret => secret,
                   :sessions => keystr})
    end
    
    def get_access_token_for_application
      client = Mogli::Client.new
      request = client.class.post(client.api_path('oauth/access_token'),
        :body=> {
          :grant_type => 'client_credentials',
          :client_id => client_id,
          :client_secret => secret
        }
      )
      Mogli::httparty_response(request).to_s.split("=").last
  end

  end
end
