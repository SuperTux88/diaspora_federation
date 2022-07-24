# frozen_string_literal: true

module DiasporaFederation
  describe Entities::Poll do
    let(:data) { Fabricate.attributes_for(:poll_entity) }

    let(:xml) { <<~XML }
      <poll>
        <guid>#{data[:guid]}</guid>
        <question>#{data[:question]}</question>
      #{data[:poll_answers].map { |a| indent(a.to_xml.to_s, 2) }.join("\n")}
      </poll>
    XML

    let(:json) { <<~JSON }
      {
        "entity_type": "poll",
        "entity_data": {
          "guid": "#{data[:guid]}",
          "question": "#{data[:question]}",
          "poll_answers": [
      #{data[:poll_answers].map { |a| indent(JSON.pretty_generate(a.to_json), 6) }.join(",\n")}
          ]
        }
      }
    JSON

    let(:string) { "Poll:#{data[:guid]}" }

    it_behaves_like "an Entity subclass"

    it_behaves_like "an XML Entity"

    it_behaves_like "a JSON Entity"
  end
end
