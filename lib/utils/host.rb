module Utils
  class Host
    class << self
      def localhost
#        url = request.url
        udp = UDPSocket.new
        # クラスBの先頭アドレス,echoポート 実際にはパケットは送信されない。
        udp.connect("128.0.0.0", 7)
        adrs = Socket.unpack_sockaddr_in(udp.getsockname)[1]
        udp.close
        url = "https://#{adrs}:3000"
        uri = URI.parse url
#        uri  = URI.parse Rails.application.default_url_options[:host]
        port = Rails.application.default_url_options[:port] || nil

        localhost = uri.host
        localhost += ":#{port}" if port.present? && ![80, 443].include?(port)

        localhost
      end

      def local_url?(url)
        uri = URI.parse url
        host = uri.host
        host += ":#{uri.port}" if uri.port && ![80, 443].include?(uri.port)

        localhost == host
      end

      def local_route(url)
        return nil unless local_url? url

        Rails.application.routes.recognize_path(url)
      rescue ActionController::RoutingError
        nil
      end
    end
  end
end

