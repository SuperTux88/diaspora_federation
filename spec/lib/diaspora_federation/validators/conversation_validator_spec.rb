# frozen_string_literal: true

module DiasporaFederation
  describe Validators::ConversationValidator do
    let(:entity) { :conversation_entity }

    it_behaves_like "a common validator"

    it_behaves_like "a diaspora* ID validator" do
      let(:property) { :author }
    end

    it_behaves_like "a guid validator" do
      let(:property) { :guid }
    end

    describe "#subject" do
      it_behaves_like "a property with a value validation/restriction" do
        let(:property) { :subject }
        let(:wrong_values) { [nil, "", "a" * 256] }
        let(:correct_values) { ["a" * 255] }
      end
    end

    describe "#messages" do
      it_behaves_like "a property with a value validation/restriction" do
        let(:property) { :messages }
        let(:wrong_values) { [nil] }
        let(:correct_values) { [[], [Fabricate(:message_entity)]] }
      end
    end

    describe "#participant_ids" do
      it_behaves_like "a property with a value validation/restriction" do
        let(:property) { :participants }
        let(:wrong_values) { ["", "foo;bar", Fabricate.sequence(:diaspora_id)] }
        let(:correct_values) do
          [
            Array.new(2) { Fabricate.sequence(:diaspora_id) }.join(";"),
            Array.new(21) { Fabricate.sequence(:diaspora_id) }.join(";")
          ]
        end
      end
    end
  end
end
