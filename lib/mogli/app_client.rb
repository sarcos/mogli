require "mogli/client/event"
require "mogli/client/user"

module Mogli
  class AppClient < Client
    attr_accessor :application_id, :user_id, :message, :data, :app_at
    
    def subscription_url
      "https://graph.facebook.com/#{application_id}/subscriptions"
    end
    
    def app_request_url
      "https://graph.facebook.com/#{user_id}/apprequests?message='#{message}'&data='#{data}'&app_access_token=#{app_at}&method=post"
    end
    
    def app_request
      options_to_send = options.dup
      options_to_send[:fields] = Array(options[:fields]).join(",")
      self.class.post(app_request_url,:body=>default_params.merge(options_to_send))
    end
    
    def subscribe_to_model(model,options)
      options_to_send = options.dup
      options_to_send[:fields] = Array(options[:fields]).join(",")
      options_to_send[:object] = name_for_class(model)
      self.class.post(subscription_url,:body=>default_params.merge(options_to_send))
    end
    
    def name_for_class(klass)
      klass.name.split("::").last.downcase
    end
    
    def subscriptions
      get_and_map_url(subscription_url,"Subscription")
    end
    
    
  end
end