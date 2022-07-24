# frozen_string_literal: true

module DiasporaFederation
  describe Entities::Embed do
    let(:data) { Fabricate.attributes_for(:embed_entity) }

    let(:xml) { <<~XML }
      <embed>
        <url>#{data[:url]}</url>
        <title>#{data[:title]}</title>
        <description>#{data[:description]}</description>
        <image>#{data[:image]}</image>
      </embed>
    XML

    let(:json) { <<~JSON }
      {
        "entity_type": "embed",
        "entity_data": {
          "url": "#{data[:url]}",
          "title": "#{data[:title]}",
          "description": "#{data[:description]}",
          "image": "#{data[:image]}"
        }
      }
    JSON

    let(:string) { "Embed:#{data[:url]}" }

    it_behaves_like "an Entity subclass"

    it_behaves_like "an XML Entity"

    it_behaves_like "a JSON Entity"

    describe "#validate" do
      it "allows 'url' to be set if 'nothing' is not true" do
        expect { Entities::Embed.new(data) }.not_to raise_error
      end

      it "allows 'url' to be missing if 'nothing' is true" do
        expect { Entities::Embed.new(nothing: true) }.not_to raise_error
      end

      it "doesn't allow 'url' to be set if 'nothing' is true" do
        expect { Entities::Embed.new(data.merge(nothing: true)) }.to raise_error(
          Entity::ValidationError,
          "Either 'url' must be set or 'nothing' must be 'true'"
        )
      end

      it "doesn't allow 'url' to be missing if 'nothing' is not true" do
        expect { Entities::Embed.new({}) }.to raise_error(
          Entity::ValidationError,
          "Either 'url' must be set or 'nothing' must be 'true'"
        )
      end
    end
  end
end
