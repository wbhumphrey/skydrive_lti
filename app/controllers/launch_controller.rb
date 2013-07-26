class LaunchController < ApplicationController
  include ActionController::Cookies

  before_filter :ensure_authenticated_user, only: :skydrive_authorized

  $oauth_creds = {
      'test' => 'secret'
  }

  def tool_provider
    require 'oauth/request_proxy/rack_request'

    key = params['oauth_consumer_key']
    secret = $oauth_creds[key]
    tp = IMS::LTI::ToolProvider.new(key, secret, params)

    if !key
      tp.lti_errorlog = "No consumer key"
    elsif !secret
      tp.lti_errorlog = "Consumer key wasn't recognized"
    elsif !tp.valid_request?(request)
      tp.lti_errorlog = "The OAuth signature was invalid"
    elsif Time.now.utc.to_i - tp.request_oauth_timestamp.to_i > 120
      tp.lti_errorlog = "Your request is too old."
    end

    #
    ## this isn't actually checking anything like it should, just want people
    ## implementing real tools to be aware they need to check the nonce
    #if was_nonce_used_in_last_x_minutes?(@tp.request_oauth_nonce, 60)
    #  register_error "Why are you reusing the nonce?"
    #  return false
    #end
    #
    ## save the launch parameters for use in later request
    ##session['launch_params'] = @tp.to_params
    #
    #@username = @tp.username("Dude")

    return tp
  end

  def basic_launch
    tp = tool_provider
    if tp.lti_errorlog
      render text: tp.lti_errorlog
      return
    end


    unless email = tp.lis_person_contact_email_primary
      render "Missing email information"
      return
    end

    unless client_domain = tp.get_custom_param('sharepoint_client_domain')
      render "Missing sharepoint client domain"
      return
    end

    user = User.where("email = ?", email).first ||
        User.create(
            name: tp.lis_person_name_full,
            username: tp.user_id,
            email: email
        )

    user.skydrive_token = SkydriveToken.create(client_domain: client_domain) unless user.skydrive_token
    user.skydrive_token.update_attributes(client_domain: client_domain) unless user.skydrive_token.client_domain
    user.cleanup_api_keys

    code = user.session_api_key.oauth_code
    redirect_to "/#/launch/#{code}"
  end

  def skydrive_authorized
    if current_user.valid_skydrive_token?
      render json: {}, status: 201
    else
      code = current_user.session_api_key.oauth_code
      client = Skydrive::Client.new(SHAREPOINT.merge(client_domain: current_user.skydrive_token.client_domain))
      redirect_uri = "#{request.protocol}#{request.host_with_port}#{microsoft_oauth_path}"
      auth_url = client.oauth_authorize_redirect(redirect_uri, state: code)
      render text: auth_url, status: 401
    end
  end

  def microsoft_oauth
    user = ApiKey.trade_oauth_code_for_access_token(params['state']).user

    client = Skydrive::Client.new(SHAREPOINT.merge(client_domain: user.skydrive_token.client_domain))
    redirect_uri = "#{request.protocol}#{request.host_with_port}#{microsoft_oauth_path}"
    results = client.get_token(redirect_uri, params['code'])
    return "#{results['error']} - #{results['error_description']}" if results.key? 'error'

    results.merge!(personal_url: client.get_user['PersonalUrl'])

    user.skydrive_token.update_attributes(results)

    redirect_to "/#/oauth/callback"
  end

  def backdoor_launch
    email = params[:email] || 'ericb@instructure.com'
    name = params[:name] || 'Eric Berry'
    username = params[:username] || 'ericb'
    user = User.where("email = ?", email).first ||
        User.create(
            name: name,
            username: username,
            email: email
        )
    user.cleanup_api_keys
    user.skydrive_token = SkydriveToken.create(client_domain: "instructure.sharepoint.com") unless user.skydrive_token
    user.skydrive_token.update_attributes(client_domain: "instructure.sharepoint.com") unless user.skydrive_token.client_domain

    code = user.session_api_key.oauth_code
    redirect_to "/#/launch/#{code}"
  end
end
