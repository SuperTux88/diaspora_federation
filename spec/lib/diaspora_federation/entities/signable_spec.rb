# frozen_string_literal: true

module DiasporaFederation
  describe Entities::Signable do
    TEST_STRING_VALUE = "abc123"

    class TestSignableEntity < Entity
      include Entities::Signable

      property :my_signature, :string, default: nil

      def signature_data
        TEST_STRING_VALUE
      end
    end

    describe "#signature_data" do
      it "raises NotImplementedError when not overridden" do
        class TestEntity < Entity
          include Entities::Signable
        end

        expect { TestEntity.new({}).signature_data }.to raise_error(NotImplementedError)
      end
    end

    it_behaves_like "a signable" do
      let(:test_class) { TestSignableEntity }
      let(:test_string) { TEST_STRING_VALUE }
    end
  end
end
