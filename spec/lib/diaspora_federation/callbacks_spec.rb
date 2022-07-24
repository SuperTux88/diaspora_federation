# frozen_string_literal: true

# rubocop:disable Lint/EmptyBlock
module DiasporaFederation
  describe Callbacks do
    subject(:callbacks) { Callbacks.new %i[some_event another_event] }

    context "callbacks" do
      it "defines a callback and calls it" do
        callbacks.on(:some_event) { "result" }

        expect(callbacks.trigger(:some_event)).to eq("result")
      end

      it "defines a callback with params and calls it" do
        callbacks.on(:some_event) { |arg1, arg2| "result: #{arg1}, #{arg2}" }

        expect(callbacks.trigger(:some_event, "foo", "bar")).to eq("result: foo, bar")
      end
    end

    describe "#on" do
      it "fails if an event is unknown" do
        expect { callbacks.on(:unknown_event) {} }.to raise_error ArgumentError, "Undefined event unknown_event"
      end

      it "fails if an event is unknown" do
        callbacks.on(:some_event) {}
        expect { callbacks.on(:some_event) {} }.to raise_error ArgumentError, "Already defined event some_event"
      end
    end

    describe "#trigger" do
      it "fails if an event is unknown" do
        expect { callbacks.trigger(:unknown_event) }.to raise_error ArgumentError, "Undefined event unknown_event"
      end
    end

    describe "#definition_complete?" do
      it "is false if nothing is defined" do
        expect(callbacks.definition_complete?).to be_falsey
      end

      it "is false if not all events are defined" do
        callbacks.on(:some_event) {}
        expect(callbacks.definition_complete?).to be_falsey
      end

      it "is true if all events are defined" do
        callbacks.on(:some_event) {}
        callbacks.on(:another_event) {}
        expect(callbacks.definition_complete?).to be_truthy
      end
    end

    describe "#missing_handlers" do
      it "contains all events if nothing isdefined" do
        expect(callbacks.missing_handlers).to eq(%i[some_event another_event])
      end

      it "contains the missing events if not all events are defined" do
        callbacks.on(:some_event) {}
        expect(callbacks.missing_handlers).to eq(%i[another_event])
      end

      it "is empty if all events are defined" do
        callbacks.on(:some_event) {}
        callbacks.on(:another_event) {}
        expect(callbacks.missing_handlers).to be_empty
      end
    end
  end
end
# rubocop:enable Lint/EmptyBlock
