module DiasporaFederation
  module Entities
    # this entity represents a participation in poll, i.e. it is issued when a user votes for an answer in a poll
    #
    # @see Validators::PollParticipationValidator
    class PollParticipation < Entity
      # old signature order
      # @deprecated
      LEGACY_SIGNATURE_ORDER = %i(guid parent_guid diaspora_id poll_answer_guid).freeze

      include Relayable

      # @!attribute [r] poll_answer_guid
      #   guid of the answer selected by the user.
      #   @see PollAnswer#guid
      #   @return [String] poll answer guid
      property :poll_answer_guid

      # The {PollParticipation} parent is a {Poll}
      # @return [String] parent type
      def parent_type
        "Poll"
      end
    end
  end
end
