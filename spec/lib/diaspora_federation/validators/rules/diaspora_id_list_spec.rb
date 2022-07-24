# frozen_string_literal: true

describe Validation::Rule::DiasporaIdList do
  let(:id_str) { Array.new(3) { Fabricate.sequence(:diaspora_id) }.join(";") }

  it "does not require a parameter" do
    validator = Validation::Validator.new({})
    expect { validator.rule(:ids, :diaspora_id_list) }.not_to raise_error
  end

  it "allows a :maximum parameter" do
    validator = Validation::Validator.new({})
    expect { validator.rule(:ids, diaspora_id_list: { maximum: 20 }) }.not_to raise_error
  end

  it "requires a integer as :maximum" do
    validator = Validation::Validator.new({})
    [nil, "", 5.5].each do |val|
      expect { validator.rule(:ids, diaspora_id_list: { maximum: val }) }.to raise_error(
        ArgumentError,
        "The :maximum needs to be an Integer"
      )
    end
  end

  it "requires a integer as :minimum" do
    validator = Validation::Validator.new({})
    [nil, "", 5.5].each do |val|
      expect { validator.rule(:ids, diaspora_id_list: { minimum: val }) }.to raise_error(
        ArgumentError,
        "The :minimum needs to be an Integer"
      )
    end
  end

  it "has an error key" do
    expect(described_class.new(maximum: 5).error_key).to eq(:diaspora_id_list)
  end

  context "when validating" do
    before { stub_const("DiasporaIdsHolder", Struct.new(:ids)) }

    it "validates less ids" do
      validator = Validation::Validator.new(DiasporaIdsHolder.new(id_str))
      validator.rule(:ids, diaspora_id_list: { maximum: 5 })

      expect(validator).to be_valid
      expect(validator.errors).to be_empty
    end

    it "fails for less but non ids" do
      bad_str = "user@example.com;i am a weird diaspora* ID @@@ ### 12345;shouldnt be reached by a rule"
      validator = Validation::Validator.new(DiasporaIdsHolder.new(bad_str))
      validator.rule(:ids, diaspora_id_list: { maximum: 5 })

      expect(validator).not_to be_valid
      expect(validator.errors).to include(:ids)
    end

    it "validates exactly as many ids" do
      validator = Validation::Validator.new(DiasporaIdsHolder.new(id_str))
      validator.rule(:ids, diaspora_id_list: { minimum: 3, maximum: 3 })

      expect(validator).to be_valid
      expect(validator.errors).to be_empty
    end

    it "validates without params" do
      validator = Validation::Validator.new(DiasporaIdsHolder.new(id_str))
      validator.rule(:ids, :diaspora_id_list)

      expect(validator).to be_valid
      expect(validator.errors).to be_empty
    end

    it "fails for too many ids" do
      validator = Validation::Validator.new(DiasporaIdsHolder.new(id_str))
      validator.rule(:ids, diaspora_id_list: { maximum: 2 })

      expect(validator).not_to be_valid
      expect(validator.errors).to include(:ids)
    end

    it "fails for too less ids" do
      validator = Validation::Validator.new(DiasporaIdsHolder.new(id_str))
      validator.rule(:ids, diaspora_id_list: { minimum: 4 })

      expect(validator).not_to be_valid
      expect(validator.errors).to include(:ids)
    end
  end
end
