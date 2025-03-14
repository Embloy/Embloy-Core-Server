# frozen_string_literal: true

module Rack
  # See https://github.com/rack/rack-attack/blob/main/docs/example_configuration.md
  class Attack
    if Rails.env.production? || Rails.env.development?
      ### Configure Cache ###

      # If you don't want to use Rails.cache (Rack::Attack's default), then
      # configure it here.
      #
      # Note: The store is only used for throttling (not blocklisting and
      # safelisting). It must implement .increment and .write like
      # ActiveSupport::Cache::Store
      Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

      ### Throttle Spammy Clients ###

      # If any single client IP is making tons of requests, then they're
      # probably malicious or a poorly-configured scraper. Either way, they
      # don't deserve to hog all of the app server's CPU. Cut them off!
      #
      # Note: If you're serving assets through rack, those requests may be
      # counted by rack-attack and this throttle may be activated too
      # quickly. If so, enable the condition to exclude them from tracking.

      # Throttle all requests by IP (60rpm)
      #
      # Key: "rack::attack:#{Time.now.to_i/:period}:req/ip:#{req.ip}"
      throttle('req/ip', limit: 300, period: 5.minutes, &:ip)

      ### Prevent Brute-Force Login Attacks ###

      # The most common brute-force login attack is a brute-force password
      # attack where an attacker simply tries a large number of emails and
      # passwords to see if any credentials match.
      #
      # Another common method of attack is to use a swarm of computers with
      # different IPs to try brute-forcing a password for a specific account.

      # Throttle POST requests to /auth/token/refresh by IP address
      #
      # Key: "rack::attack:#{Time.now.to_i/:period}:logins/ip:#{req.ip}"
      throttle('logins/refresh/ip', limit: 5, period: 20.seconds) do |req|
        req.ip if req.path == '/api/v0/auth/token/refresh' && req.post?
      end

      # Throttle POST requests to /auth/token/access by IP address
      #
      # Key: "rack::attack:#{Time.now.to_i/:period}:logins/ip:#{req.ip}"
      throttle('logins/access/ip', limit: 5, period: 20.seconds) do |req|
        req.ip if req.path == '/api/v0/auth/token/access' && req.post?
      end

      ### Custom Throttle Response ###

      # By default, Rack::Attack returns an HTTP 429 for throttled responses,
      # which is just fine.
      #
      # If you want to return 503 so that the attacker might be fooled into
      # believing that they've successfully broken your app (or you just want to
      # customize the response), then uncomment these lines.
      self.throttled_responder = lambda do |_env|
        [503, # status
         {}, # headers
         ['Rate limit exceeded. Please try again later.']] # body
      end
    end
  end
end
