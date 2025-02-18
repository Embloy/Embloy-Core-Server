# frozen_string_literal: true

require 'faraday'
require 'tempfile'

# OauthCallbacksController handles oauth-related actions
class OauthCallbacksController < ApplicationController
  skip_before_action :require_user_not_blacklisted!

  def github
    authenticate
    # TODO: FETCH ADDITIONAL METADATA
  end

  def google
    authenticate
    # TODO: FETCH ADDITIONAL METADATA
  end

  def azure
    authenticate
    # TODO: FETCH ADDITIONAL METADATA
  end

  def linkedin
    authenticate
    # TODO: FETCH ADDITIONAL METADATA
  end

  def auth
    Rails.logger.debug("auth=#{request.env['omniauth.auth']}")
    request.env['omniauth.auth']
  end

  private

  def authenticate
    redirect_to("#{ENV.fetch('CORE_CLIENT_URL')}/oauth/redirect?error=Invalid email or password", allow_other_host: true) and return if auth.info.email.nil?

    user = User.find_by(email: auth.info.email)
    user.present? ? handle_existing_user(user) : handle_new_user
  end

  def handle_existing_user(user)
    refresh_token = AuthenticationTokenService::Refresh::Encoder.call(user)
    redirect_to("#{ENV.fetch('CORE_CLIENT_URL')}/oauth/redirect?refresh_token=#{refresh_token}", allow_other_host: true) and return
  end

  def handle_new_user
    user = create_new_user
    return unless user.save!

    attach_user_image(user)
    # WelcomeMailer.with(user:).welcome_email.deliver_later # <-- OAuth users don't need e-mail verification
    WelcomeMailer.with(user:).notify_team.deliver_later
    refresh_token = AuthenticationTokenService::Refresh::Encoder.call(user)
    redirect_to("#{ENV.fetch('CORE_CLIENT_URL')}/oauth/redirect?refresh_token=#{refresh_token}", allow_other_host: true) and return
  end

  def create_new_user
    pw = SecureRandom.hex
    User.new(
      email: auth.info.email,
      password: pw,
      password_confirmation: pw,
      first_name: auth.info.name.split[0],
      last_name: auth.info.name.split[1],
      user_role: 'verified',
      activity_status: 1
    )
  end

  def attach_user_image(user)
    return unless auth.info.image

    response = Faraday.get(auth.info.image)
    raise 'Unable to download image' unless response.success?

    Tempfile.open(['image', '.jpg']) do |tempfile|
      tempfile.binmode
      tempfile.write(response.body)
      tempfile.rewind

      user.image_url.attach(io: tempfile, filename: 'image.jpg', content_type: response.headers['content-type'])
    end
  rescue ActiveStorage::IntegrityError
    default_image = Rails.root.join('app/assets/images/logo-light.svg')
    user.image_url.attach(io: File.open(default_image), filename: 'default.svg', content_type: 'image/svg')
  rescue StandardError => e
    redirect_to("#{ENV.fetch('CORE_CLIENT_URL')}/oauth/redirect?error=#{e.message}", allow_other_host: true) and return
  end
end
