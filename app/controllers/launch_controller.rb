class LaunchController < ApplicationController
  include ActionController::Cookies

  $microsoft_client = {
      client_id: "044b1397-bc56-4db3-9197-5fabcc834e6a",
      client_secret: "68znNygVFZbfPn+X+cEdAILu+LE/5Z2+3fvVxx7DmkI=",
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
    if user.skydrive_token
      redirect_to "/?code=#{code}"
    else
      redirect_uri = "#{request.protocol}#{request.host_with_port}#{microsoft_oauth_path}?lti_code=#{code}&referrer=#{CGI::escape(request.referrer)}"
      redirect_to Skydrive::Client.new($microsoft_client).oauth_authorize_redirect(redirect_uri)
    end
  end

  def microsoft_oauth
    binding.pry
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
    redirect_to "/?code=#{user.session_api_key.oauth_code}"
  end
end
