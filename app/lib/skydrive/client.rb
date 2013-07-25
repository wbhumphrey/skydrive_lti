require 'rest_client'
require 'json'

module Skydrive
  class Client
    attr_accessor :client_id, :client_secret, :guid, :client_domain, :token

    def initialize(options = {})
      options.each { |key, val| self.send("#{key}=", val) if self.respond_to?("#{key}=") }
    end

    def oauth_authorize_redirect(redirect_uri, options = {})
      scope = options[:scope] || 'Web.Write'
      state = options[:state]

      redirect_params = {
          client_id: client_id,
          scope: scope,
          redirect_uri: redirect_uri,
          response_type: 'code'
      }

      "https://#{client_domain}/_layouts/15/OAuthAuthorize.aspx?" +
          redirect_params.map{|k,v| "#{k}=#{CGI::escape(v)}"}.join('&') +
          (state ? "&state=#{state}" : "")
    end

    def get_token(redirect_uri, code)
      realm = self.get_realm
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
        format_results(JSON.parse(response))
      end
    end

    def refresh_token(refresh_token)
      realm = self.get_realm
      endpoint = "https://accounts.accesscontrol.windows.net/#{realm}/tokens/OAuth/2"

      options = {
          content_type: 'application/x-www-form-urlencoded',
          client_id: "#{client_id}@#{realm}",
          client_secret: client_secret,
          refresh_token: refresh_token,
          grant_type: 'refresh_token',
          resource: "#{guid}/#{client_domain}@#{realm}",
      }

      RestClient.post endpoint, options do |response, request, result|
        format_results(JSON.parse(response))
      end
    end

    def format_results(results)
      results["expires_in"] = results["expires_in"].to_i
      results["not_before"] = Time.at results["not_before"].to_i
      results["expires_on"] = Time.at results["expires_on"].to_i
      results
    end

    def get_realm
      #401 sharepoint challenge to get the realm
      resource = RestClient::Resource.new "https://#{client_domain}/_vti_bin/client.svc/",
                                          {headers: {'Authorization' => 'Bearer'}}
      www_authenticate = {}
      resource.get do |response, request, result|
        response.headers[:www_authenticate].scan(/[\w ]*="[^"]*"/).each do |attribute|
          attribute = attribute.split('=')
          www_authenticate[attribute.first] = attribute.last.delete('"')
        end
      end

      www_authenticate["Bearer realm"]
    end

    def api_call()
      RestClient.get "https://apis.live.net/v5.0/me/skydrive?access_token=#{token}"
    end
  end
end