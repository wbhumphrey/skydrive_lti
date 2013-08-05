class LaunchController < ApplicationController
  include ActionController::Cookies

  before_filter :ensure_authenticated_user, only: :skydrive_authorized

  def tool_provider
    require 'oauth/request_proxy/rack_request'

    lti_key = LtiKey.where(key: params['oauth_consumer_key']).first

    if lti_key
      key = lti_key.key
      secret = lti_key.secret
    end

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
      render text: tp.lti_errorlog, status: 400
      return
    end

    email = tp.lis_person_contact_email_primary
    unless email.present?
      render text: "Missing email information"
      return
    end

    unless client_domain = tp.get_custom_param('sharepoint_client_domain')
      render text: "Missing sharepoint client domain", status: 400
      return
    end

    user = User.where(email: email).first ||
        User.create!(
            name: tp.lis_person_name_full,
            username: tp.user_id,
            email: email
        )

    user.skydrive_token = SkydriveToken.create(client_domain: "#{client_domain}-my.sharepoint.com") unless user.skydrive_token
    user.skydrive_token.update_attributes(client_domain: "#{client_domain}-my.sharepoint.com") unless user.skydrive_token.client_domain
    user.cleanup_api_keys

    code = user.session_api_key(params).oauth_code

    redirect_to "/#/launch/#{code}"
  end

  def skydrive_authorized
    if current_user.valid_skydrive_token?
      render json: {}, status: 201
    else
      code = current_user.api_keys.active.skydrive_oauth.create.oauth_code
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

  def xml_config
    # ie http://localhost:9393/config?sharepoint_client_domain=instructure-my.sharepoint.com
    if params['sharepoint_client_domain']
      url = "#{request.protocol}#{request.host_with_port}#{launch_path}"
      title = "Skydrive Pro"
      tc = IMS::LTI::ToolConfig.new(:title => title, :launch_url => url)
      tc.extend IMS::LTI::Extensions::Canvas::ToolConfig
      tc.description = 'Allows you to pull in documents from Skydrive Pro to canvas'
      tc.canvas_privacy_public!
      tc.canvas_domain!(request.host)
      tc.canvas_icon_url!("#{request.protocol}#{request.host_with_port}/images/skydrive_icon.png")
      tc.canvas_selector_dimensions!(700,600)
      tc.canvas_text!(title)
      tc.canvas_homework_submission!
      tc.canvas_editor_button!
      tc.canvas_resource_selection!
      tc.canvas_account_navigation!
      tc.canvas_course_navigation!
      tc.canvas_user_navigation!
      tc.set_ext_param(
          IMS::LTI::Extensions::Canvas::ToolConfig::PLATFORM, :custom_fields,
          {sharepoint_client_domain: params['sharepoint_client_domain']})
      render xml: tc.to_xml
    else
      render text: 'The sharepoint_client_domain is a required parameter.'
    end
  end
end
