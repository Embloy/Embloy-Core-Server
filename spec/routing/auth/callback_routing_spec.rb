# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'OauthCallbacksController', type: :routing do
  describe 'routing' do
    it 'routes to #github' do
      expect(get: '/auth/github/callback').to route_to('oauth_callbacks#github')
    end

    it 'routes to #google' do
      expect(get: '/auth/google_oauth2/callback').to route_to('oauth_callbacks#google')
    end

    it 'routes to #azure' do
      expect(get: '/auth/azure_activedirectory_v2/callback').to route_to('oauth_callbacks#azure')
    end

    it 'routes to #linkedin' do
      expect(get: '/auth/linkedin/callback').to route_to('oauth_callbacks#linkedin')
    end

    it 'routes to #lever' do
      expect(get: '/auth/lever/callback').to route_to('integrations/lever/oauth#callback')
      expect(get: '/api/v0/integrations/lever/auth').to route_to('integrations/lever/oauth#authorize')
    end
  end
end
