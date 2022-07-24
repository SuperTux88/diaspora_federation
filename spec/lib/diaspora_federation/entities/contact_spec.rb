# frozen_string_literal: true

module DiasporaFederation
  describe Entities::Contact do
    let(:data) { Fabricate.attributes_for(:contact_entity) }

    let(:xml) { <<~XML }
      <contact>
        <author>#{data[:author]}</author>
        <recipient>#{data[:recipient]}</recipient>
        <following>#{data[:following]}</following>
        <sharing>#{data[:sharing]}</sharing>
        <blocking>#{data[:blocking]}</blocking>
      </contact>
    XML

    let(:string) { "Contact:#{data[:author]}:#{data[:recipient]}" }

    it_behaves_like "an Entity subclass"

    it_behaves_like "an XML Entity"

    describe "#validate" do
      it "allows 'following' and 'sharing' to be true" do
        combinations = [
          { following: true, sharing: true, blocking: false },
          { following: true, sharing: false, blocking: false },
          { following: false, sharing: true, blocking: false }
        ]
        combinations.each { |combination| expect { Entities::Contact.new(data.merge(combination)) }.not_to raise_error }
      end

      it "allows 'blocking' to be true" do
        expect {
          Entities::Contact.new(data.merge(following: false, sharing: false, blocking: true))
        }.not_to raise_error
      end

      it "doesn't allow 'following'/'sharing' and 'blocking' to be true" do
        combinations = [
          { following: true, sharing: true, blocking: true },
          { following: true, sharing: false, blocking: true },
          { following: false, sharing: true, blocking: true }
        ]
        combinations.each do |combination|
          expect { Entities::Contact.new(data.merge(combination)) }.to raise_error Entity::ValidationError
        end
      end
    end
  end
end
