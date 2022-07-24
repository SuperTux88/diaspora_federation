# frozen_string_literal: true

module DiasporaFederation
  # diaspora* federation rails engine
  class Engine < ::Rails::Engine
    isolate_namespace DiasporaFederation

    config.generators { |g| g.test_framework :rspec }

    config.after_initialize { DiasporaFederation.validate_config }
  end
end
