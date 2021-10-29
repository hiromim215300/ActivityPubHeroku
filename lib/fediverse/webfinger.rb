require 'utils/host'

module Fediverse
  class Webfinger
    class << self
      ACCOUNT_REGEX = /(?<username>[a-z0-9\-_.]+)(?:@(?<domain>.*))?/.freeze

      def split_resource_account(account)
        /\Aacct:#{ACCOUNT_REGEX}\z/i.match account
      end

      def split_account(account)
        /\A#{ACCOUNT_REGEX}\z/i.match account
      end

      def local_user?(account)
        account[:username] && (account[:domain].nil? || (account[:domain] == Utils::Host.localhost))
      end

      def fetch_actor(username, domain)
        fetch_actor_url webfinger(username, domain)
      end

      def fetch_actor_url(url)
        webfinger_to_actor get_json url
      end

      # Returns actor id
      def webfinger(username, domain)
        scheme = Rails.application.config.site.https_interactions ? 'https' : 'http'
        json = get_json "#{scheme}://#{domain}/.well-known/webfinger", resource: "acct:#{username}@#{domain}"
        link = json['links'].find { |l| l['type'] == 'application/activity+json' }

        return link['href'] if link
      end

      private

      def webfinger_to_actor(data) # rubocop:disable Metrics/AbcSize
        uri    = URI.parse data['id']
        server = uri.host
        server += ":#{uri.port}" if uri.port && ![80, 443].include?(uri.port)
        ::Actor.new federated_url:  data['id'],
                    username:       data['preferredUsername'],
                    name:           data['name'],
                    server:         server,
                    inbox_url:      data['inbox'],
                    outbox_url:     data['outbox']
                  #  followers_url:  data['followers'],
                  #  followings_url: data['following'],
                  #  profile_url:    data['url']
      end

      def get_json(url, payload = {})
        begin
          response = Faraday.get url, payload, accept: 'application/json'
        rescue Faraday::ConnectionFailed
          Rails.logger.debug "Failed to reach server for GET #{url}"
          raise ActiveRecord::RecordNotFound
        end

        if response.status != 200
          Rails.logger.debug "Unhandled status code #{response.status} for GET #{url}"
          raise ActiveRecord::RecordNotFound
        end

        # FIXME: handle JSON parsing errors
        JSON.parse(response.body)
      end
    end
  end
end

