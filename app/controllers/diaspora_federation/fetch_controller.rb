# frozen_string_literal: true

require_dependency "diaspora_federation/application_controller"

module DiasporaFederation
  # This controller processes fetch requests.
  class FetchController < ApplicationController
    # Returns the fetched entity or a redirect
    #
    # GET /fetch/:type/:guid
    def fetch
      entity = fetch_public_entity
      if entity
        magic_env = create_magic_envelope(entity)
        if magic_env
          render xml: magic_env, content_type: "application/magic-envelope+xml"
        else
          redirect_url =
            DiasporaFederation.callbacks.trigger(
              :fetch_person_url_to,
              entity.author,
              "/fetch/#{params[:type]}/#{params[:guid]}"
            )
          redirect_to redirect_url, allow_other_host: true
        end
      else
        head :not_found
      end
    end

    private

    def fetch_public_entity
      type = DiasporaFederation::Entity.entity_class(params[:type]).to_s.rpartition("::").last
      DiasporaFederation.callbacks.trigger(:fetch_public_entity, type, params[:guid])
    end

    def create_magic_envelope(entity)
      privkey = DiasporaFederation.callbacks.trigger(:fetch_private_key, entity.author)
      Salmon::MagicEnvelope.new(entity, entity.author).envelop(privkey) if privkey
    end
  end
end
