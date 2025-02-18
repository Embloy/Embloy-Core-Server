# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'
require 'jwt'

module Integrations
  module Lever
    # OauthController handles all OAuth-related actions for Lever
    class OauthController < Api::V0::ApiController
      OAUTH_URL = 'https://auth.lever.co'
      SANDBOX_OAUTH_URL = 'https://sandbox-lever.auth0.com'
      OAUTH_PATH = '/authorize'
      ACCESS_TOKEN_PATH = '/oauth/token'
      REDIRECT_URL = 'https://genius.embloy.com/settings?tab=secrets'

      before_action :must_be_verified!, only: %i[authorize]
      before_action :must_be_subscribed!, only: %i[authorize]
      skip_before_action :require_user_not_blacklisted!, only: %i[callback]
      skip_before_action :set_current_user, only: %i[callback]

      def oauth_url(client, path = '')
        Rails.logger.debug("Starting Lever OAuth process for #{client.sandboxd? ? 'sandbox' : 'production'} environment")
        URI((client.sandboxd? ? SANDBOX_OAUTH_URL : OAUTH_URL) + path)
      end

      def self.oauth_url(client, path = '')
        Rails.logger.debug("Starting Lever OAuth process for #{client.sandboxd? ? 'sandbox' : 'production'} environment")
        URI((client.sandboxd? ? SANDBOX_OAUTH_URL : OAUTH_URL) + path)
      end

      # Called via 'localhost:3000/integrations/auth/lever' and redirects to Lever OAuth app (step 1)
      # Reference: https://hire.sandbox.lever.co/developer/documentation#scopes
      def authorize
        client_id = ENV.fetch(Current.user.sandboxd? ? 'LEVER_SANDBOX_CLIENT_ID' : 'LEVER_CLIENT_ID', nil)
        state = Current.user.signed_id(purpose: 'lever_oauth_state', expires_in: 1.hour)
        audience = Current.user.sandboxd? ? 'https://api.sandbox.lever.co/v1/' : 'https://api.lever.co/v1/'
        scope = Current.user.sandboxd? ? 'offline_access postings:write:admin uploads:write:admin webhooks:write:admin stages:read:admin archive_reasons:read:admin opportunities:read:admin' : 'offline_access postings:write:admin uploads:write:admin webhooks:write:admin' # TODO: Add scopes required by webhooks # rubocop:disable Layout/LineLength

        url = "#{oauth_url(Current.user,
                           OAUTH_PATH)}?client_id=#{client_id}&redirect_uri=#{auth_lever_callback_url}&state=#{state}&response_type=code&scope=#{scope}&prompt=consent&audience=#{audience}"
        render json: { url: }, status: :ok
      end

      # Callback method for Lever OAuth app (step 2) to request access and refresh token (step 3)
      # Reference: https://hire.sandbox.lever.co/developer/documentation#authentication
      def callback
        redirect_to_error(params['error'], params['error_description']) and return if params['error']

        state = params['state']
        user = User.find_signed!(state, purpose: 'lever_oauth_state')
        redirect_to_error('invalid_state') and return unless user

        response = make_http_request(user, params['code'])
        handle_http_response(response, user)
      end

      private

      # Redirect to Genius client with error message if something goes wrong
      def redirect_to_error(error, description = nil)
        redirect_to "#{ENV.fetch('GENIUS_CLIENT_URL')}/settings?tab=integrations?error=#{error}&error_description=#{description}",
                    allow_other_host: true
      end

      # Make initial authorization request to Lever API (returns access token and refresh token)
      def make_http_request(client, code)
        url = oauth_url(client, ACCESS_TOKEN_PATH)
        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true
        request = Net::HTTP::Post.new(url)
        request.content_type = 'application/x-www-form-urlencoded'
        request.body = URI.encode_www_form({
                                             'client_id' => ENV.fetch(client.sandboxd? ? 'LEVER_SANDBOX_CLIENT_ID' : 'LEVER_CLIENT_ID', nil),
                                             'client_secret' => ENV.fetch(client.sandboxd? ? 'LEVER_SANDBOX_CLIENT_SECRET' : 'LEVER_CLIENT_SECRET', nil),
                                             'grant_type' => 'authorization_code',
                                             'code' => code,
                                             'scope' => client.sandboxd? ? 'offline_access postings:write:admin uploads:write:admin webhooks:write:admin stages:read:admin archive_reasons:read:admin opportunities:read:admin' : 'offline_access postings:write:admin uploads:write:admin webhooks:write:admin', # rubocop:disable Layout/LineLength
                                             'redirect_uri' => auth_lever_callback_url
                                           })

        http.request(request)
      end

      # Handle HTTP response from Lever authorization request and save new tokens
      def handle_http_response(response, user)
        case response
        when Net::HTTPSuccess
          response_body = JSON.parse(response.body)
          Token.save_token(user, 'OAuth Access Token', 'lever', 'access_token', response_body['access_token'], Time.now.utc + response_body['expires_in'], Time.now.utc)
          Token.save_token(user, 'OAuth Refresh Token', 'lever', 'refresh_token', response_body['refresh_token'], Time.now.utc + 1.year, Time.now.utc)
          WebhooksController.refresh_webhooks(user)
          LeverController.synchronize(user)
          redirect_to("#{ENV.fetch('GENIUS_CLIENT_URL')}/settings?tab=integrations?success=Successfully connected to Lever", allow_other_host: true)
        else
          exception_class = {
            'Net::HTTPUnauthorized' => CustomExceptions::InvalidInput::Quicklink::OAuth::Unauthorized,
            'Net::HTTPForbidden' => CustomExceptions::InvalidInput::Quicklink::OAuth::Forbidden,
            'Net::HTTPNotFound' => CustomExceptions::InvalidInput::Quicklink::OAuth::NotFound,
            'Net::HTTPNotAcceptable' => CustomExceptions::InvalidInput::Quicklink::OAuth::NotAcceptable
          }[response.class.name]
          raise exception_class if exception_class
        end
      end
    end
  end
end
