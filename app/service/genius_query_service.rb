# frozen_string_literal: true

class GeniusQueryService < AuthenticationTokenService
  HMAC_SECRET = ENV['GENIUS_QUERY_TOKEN_SECRET']
  ALGORITHM_TYPE = 'HS256'
  ISSUER = Socket.gethostname
  REPLACEMENT_CHARACTER = '°'

  def self.encode(sub, exp, jti, iat, args)
    payload = { sub: sub, exp: exp, jti: jti, iat: iat }.merge(args)
    return AuthenticationTokenService.call(HMAC_SECRET, ALGORITHM_TYPE, ISSUER, payload)
  end


  def self.decode(token)
    decoded_token = JWT.decode(token, HMAC_SECRET, true, { verify_jti: Proc.new { |jti| AuthenticationTokenService::Refresh.jti?(jti, token["sub"].to_i) }, iss: ISSUER, verify_iss: true, verify_iat: true, required_claims: ['iss', 'sub', 'exp', 'jti', 'iat'], algorithm: ALGORITHM_TYPE })
    return decoded_token
  end

  class Encoder
    MAX_INTERVAL = 31557600 # == 12 months == 1 year
    MIN_INTERVAL = 60 # == 1 min

    def self.call(user_id, args)
      AuthenticationTokenService::Refresh.verify_user_id(user_id)
      ApplicationController.must_be_verified!(user_id)
      iat = Time.now.to_i
      sub = user_id

      unless args.include?("expires_at") && !args["expires_at"].nil?
        bin_exp = iat + 3600 # standard validity interval (1 hour == 60 min == 3600 sec)
      else
        bin_exp = iat + AuthenticationTokenService::Refresh.verify_expiration(args["expires_at"], MAX_INTERVAL, MIN_INTERVAL)
        args.delete("expires_at")
      end
      exp = bin_exp
      jti = AuthenticationTokenService::Refresh.jti(iat)
      return GeniusQueryService.encode(sub, exp, jti, iat, args).gsub('.', REPLACEMENT_CHARACTER)


    end
  end

  class Decoder
    def self.call(user_id, token)
      AuthenticationTokenService::Refresh.verify_user_id(user_id) # this belongs to the user making the request (from the access token)
      if token.class != String || token.blank? # rough check whether
        raise CustomExceptions::InvalidInput::Token

      else
        return GeniusQueryService.decode(token.gsub(REPLACEMENT_CHARACTER, '.'))

      end
    end
  end
end
