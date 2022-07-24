# frozen_string_literal: true

module DiasporaFederation
  describe Validators::OptionalAwareValidator do
    def entity_stub(additional_data = {})
      allow_any_instance_of(Entities::TestComplexEntity).to receive(:freeze)
      allow_any_instance_of(Entities::TestComplexEntity).to receive(:validate)
      entity_data = {
        test1: "abc",
        test2: true,
        test3: nil,
        test4: nil,
        test5: nil,
        test6: nil,
        test7: "abc",
        multi: []
      }
      Entities::TestComplexEntity.new(entity_data.merge(additional_data))
    end

    it "validates a valid object" do
      validator = Validators::TestComplexEntityValidator.new(entity_stub)
      expect(validator).to be_valid
      expect(validator.errors).to be_empty
    end

    it "fails when a mandatory property is invalid" do
      ["ab", nil].each do |val|
        validator = Validators::TestComplexEntityValidator.new(entity_stub(test1: val))
        expect(validator).not_to be_valid
        expect(validator.errors).to include(:test1)
      end
    end

    it "fails when an optional property is invalid" do
      validator = Validators::TestComplexEntityValidator.new(entity_stub(test7: "ab"))
      expect(validator).not_to be_valid
      expect(validator.errors).to include(:test7)
    end

    it "allows an optional property to be nil" do
      validator = Validators::TestComplexEntityValidator.new(entity_stub(test7: nil))
      expect(validator).to be_valid
      expect(validator.errors).to be_empty
    end

    it "doesn't ignore 'not_nil' rules for an optional property" do
      validator = Validators::TestComplexEntityValidator.new(entity_stub(multi: nil))
      expect(validator).not_to be_valid
      expect(validator.errors).to include(:multi)
    end

    it "doesn't fail when the entity doesn't have optional props" do
      entity = Struct.new(:test1).new(nil)
      validator = Validators::TestUnknownEntityValidator.new(entity)
      expect(validator).not_to be_valid
      expect(validator.errors).to include(:test1)
    end
  end
end
