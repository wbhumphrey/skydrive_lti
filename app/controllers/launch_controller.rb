class LaunchController < ApplicationController
  include ActionController::Cookies

  $microsoft_client = {
      client_id: "00a878a3-fde7-47a3-9c89-3c9912e6bb83",
      client_secret: "MO2cbtapMB22kKEKqNsTDTVUN0vwS1vNjqaCG+NejaI=",
      guid: "00000003-0000-0ff1-ce00-000000000000",
      client_domain: "instructure.sharepoint.com"
  }

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

    email = tp.lis_person_contact_email_primary
    if !email
      render "Missing email information"
      return
    end

    user = User.where("email = ?", email).first ||
        User.create(
            name: tp.lis_person_name_full,
            username: tp.user_id,
            email: email
        )
    user.cleanup_api_keys

    code = user.session_api_key.oauth_code
    # if user.skydrive_token
      redirect_to "/?code=#{code}"
    # else
    #   redirect_uri = "#{request.protocol}#{request.host_with_port}#{microsoft_oauth_path}"
    #   redirect_to Skydrive::Client.new($microsoft_client).oauth_authorize_redirect(redirect_uri, state: code)
    # end
  end

  def skydrive_authorized
    if current_user && current_user.skydrive_token && current_user.skydrive_token.expires_on > Time.now
      render json: {}, status: 201
    else
      code = current_user.session_api_key.oauth_code
      redirect_uri = "#{request.protocol}#{request.host_with_port}#{microsoft_oauth_path}"
      auth_url = Skydrive::Client.new($microsoft_client).oauth_authorize_redirect(redirect_uri, state: code)
      render text: auth_url, status: 401
    end
  end

  def microsoft_oauth
    redirect_uri = "#{request.protocol}#{request.host_with_port}#{microsoft_oauth_path}"
    result = Skydrive::Client.new($microsoft_client).get_token(redirect_uri, params['code'])
    return "#{result['error']} - #{result['error_description']}" if result.key? 'error'

    api_key = ApiKey.trade_oauth_code_for_access_token(params['state'])

    result["not_before"] = Time.at result["not_before"].to_i
    result["expires_on"] = Time.at result["expires_on"].to_i
    api_key.user.skydrive_token = SkydriveToken.new(result)

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

    code = user.session_api_key.oauth_code
    # if user.skydrive_token
      redirect_to "/?code=#{code}"
    # else
    #   redirect_uri = "#{request.protocol}#{request.host_with_port}#{microsoft_oauth_path}"
    #   redirect_to Skydrive::Client.new($microsoft_client).oauth_authorize_redirect(redirect_uri, state: code)
    # end
  end
end
