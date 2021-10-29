module Routeable
  extend ActiveSupport::Concern

  included do
    include Rails.application.routes.url_helpers
  end

  def default_url_options
    { host: Rails.application.config.site.host, port: Rails.application.config.site.port }
  end
end

