# frozen_string_literal: true

module DiasporaFederation
  describe Validators::PollValidator do
    let(:entity) { :poll_entity }

    it_behaves_like "a common validator"

    describe "#guid" do
      it_behaves_like "a guid validator" do
        let(:property) { :guid }
      end
    end

    describe "#question" do
      it_behaves_like "a property with a value validation/restriction" do
        let(:property) { :question }
        let(:wrong_values) { [nil, "", "a" * 256] }
        let(:correct_values) { ["a" * 255] }
      end
    end

    describe "#poll_answers" do
      it_behaves_like "a property with a value validation/restriction" do
        let(:property) { :poll_answers }
        let(:wrong_values) { [nil, [Fabricate.attributes_for(:poll_answer_entity)]] }
        let(:correct_values) do
          [
            Array.new(2) { Fabricate(:poll_answer_entity) },
            Array.new(5) { Fabricate(:poll_answer_entity) }
          ]
        end
      end
    end
  end
end
