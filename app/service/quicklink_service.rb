# frozen_string_literal: true

# The QuicklinkService class is responsible for handling the server-side authorization
# part of the Embloy application process. It includes two nested classes, Client and Request,
# which handle the encoding and decoding of client and request tokens respectively.
class QuicklinkService < AuthenticationTokenService
  # The Client class is responsible for handling client tokens. These tokens are used
  # to authenticate the server making requests to Embloy's API.
  class Client
    HMAC_SECRET = ENV['CLIENT_TOKEN_SECRET']
    ALGORITHM_TYPE = 'HS256'
    ISSUER = Socket.gethostname
    REPLACEMENT_CHARACTER = '°'

    # Encodes a client token with the given payload.
    def self.encode(sub, exp, typ, iat)
      payload = { sub:, exp:, typ:, iat: }
      AuthenticationTokenService.call(
        HMAC_SECRET, ALGORITHM_TYPE, ISSUER, payload
      )
    end

    # Decodes a client token and returns the decoded payload.
    def self.decode(token)
      JWT.decode(token, HMAC_SECRET, true,
                 { iss: ISSUER, verify_iss: true, verify_iat: true, required_claims: %w[iss sub exp typ iat], algorithm: ALGORITHM_TYPE })
    end

    # The Encoder class is responsible for encoding client tokens.
    class Encoder
      # Encodes a client token for a given user ID and subscription and expiration date.
      def self.call(user_id, subscription, custom_exp)
        must_be_verified_and_subscription(user_id)
        exp = calculate_expiration(custom_exp, subscription)
        typ = subscription.tier # Needed for quick authorization when token is used
        iat = Time.now.to_i
        QuicklinkService::Client.encode(123, exp.to_i, typ, iat)
      end

      def self.must_be_verified_and_subscription(user_id)
        AuthenticationTokenService::Refresh.must_be_verified_id!(user_id)
        ApplicationController.must_be_verified!(user_id)
      end

      def self.calculate_expiration(custom_exp, subscription)
        exp = if custom_exp.nil? || custom_exp < Time.now
                Time.now.to_i + 60 * 60 * 24 * 31 * 3 # standard validity interval: 3 months or end of subscription
              else
                custom_exp.to_i # Set custom expiration date if available
              end

        exp > subscription.expiration_date.to_i ? subscription.expiration_date.to_i : exp # Token can't be valid longer than subscription
      end
    end

    # The Decoder class is responsible for decoding client tokens.
    class Decoder
      # Decodes a client token.
      def self.call(token)
        raise CustomExceptions::InvalidInput::Quicklink::Client::Malformed if token.class != String
        raise CustomExceptions::InvalidInput::Quicklink::Client::Blank if token[0] == ':' || token.blank?

        QuicklinkService::Client.decode(token)
      end
    end
  end

  # The Request class is responsible for handling request tokens. These tokens are used
  # to authenticate the user's application request to Embloy's API and communicate the selected job.
  class Request
    HMAC_SECRET = ENV['REQUEST_TOKEN_SECRET']
    ALGORITHM_TYPE = 'HS256'
    ISSUER = Socket.gethostname
    REPLACEMENT_CHARACTER = '°'

    # Encodes a request token with the given payload.
    def self.encode(sub, exp, job, iat)
      payload = { sub:, exp:, job:, iat: }
      AuthenticationTokenService.call(
        HMAC_SECRET, ALGORITHM_TYPE, ISSUER, payload
      )
    end

    # Decodes a request token and returns the decoded payload.
    def self.decode(token)
      JWT.decode(token, HMAC_SECRET, true,
                 { iss: ISSUER, verify_iss: true, verify_iat: true, required_claims: %w[iss sub exp job iat], algorithm: ALGORITHM_TYPE })
    end

    # The Encoder class is responsible for encoding request tokens.
    class Encoder
      # Encodes a request token for a given job slug and user ID.
      def self.call(user_id, job_slug)
        sub = user_id
        AuthenticationTokenService::Refresh.must_be_verified_id!(user_id)
        ApplicationController.must_be_verified!(user_id)
        # TODO: @cb verify job / account validity / price category?
        job = job_slug
        exp = Time.now.to_i + 60 * 60 * 30 # standard validity interval: 30 minutes
        iat = Time.now.to_i
        QuicklinkService::Request.encode(sub,
                                         exp, job, iat)
      end
    end

    # The Decoder class is responsible for decoding request tokens.
    class Decoder
      # Decodes a request token.
      def self.call(token)
        raise CustomExceptions::InvalidInput::Quicklink::Request::Malformed if token.class != String
        raise CustomExceptions::InvalidInput::Quicklink::Request::Blank if token[0] == ':' || token.blank?

        QuicklinkService::Request.decode(token)
      end
    end
  end
end
