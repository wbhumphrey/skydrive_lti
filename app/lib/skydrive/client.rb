require 'rest_client'
require 'json'

module Skydrive
  class Client
    attr_accessor :client_id, :client_secret, :guid, :client_domain, :token

    def initialize(options = {})
      options.each { |key, val| self.send("#{key}=", val) if self.respond_to?("#{key}=") }
    end

    def oauth_authorize_redirect(redirect_uri, scope = 'Web.Write')
      redirect_params = {
          client_id: client_id,
          scope: scope,
          redirect_uri: redirect_uri,
          response_type: 'code'
      }

      "https://#{client_domain}/_layouts/15/OAuthAuthorize.aspx?" +
                   redirect_params.map{|k,v| "#{k}=#{CGI::escape(v)}"}.join('&')
    end

    def get_token(redirect_uri, code)
      #401 sharepoint challange to get the realm
      resource = RestClient::Resource.new "https://#{client_domain}/_vti_bin/client.svc/",
                                          {headers: {'Authorization' => 'Bearer'}}
      www_authenticate = {}
      resource.get do |response, request, result|
        response.headers[:www_authenticate].scan(/[\w ]*="[^"]*"/).each do |attribute|
          attribute = attribute.split('=')
          www_authenticate[attribute.first] = attribute.last.delete('"')
        end
      end

      realm = www_authenticate["Bearer realm"]
      endpoint = "https://accounts.accesscontrol.windows.net/#{realm}/tokens/OAuth/2"

      options = {
          content_type: 'application/x-www-form-urlencoded',
          client_id: "#{client_id}@#{realm}",
          redirect_uri: redirect_uri,
          client_secret: client_secret,
          code: code,
          grant_type: 'authorization_code',
          resource: "#{guid}/#{client_domain}@#{realm}",
      }

      RestClient.post endpoint, options do |response, request, result|
        json = JSON.parse(response)
        token = json['access_token'] if json.key? 'access_token'
        json
      end
    end

    def api_call()
      RestClient.get "https://apis.live.net/v5.0/me/skydrive?access_token=#{token}"
    end
  end
end