# frozen_string_literal: true

module DiasporaFederation
  describe Parsers::BaseParser do
    describe ".parse" do
      it "raises NotImplementedError error" do
        expect { Parsers::BaseParser.new(Entity).parse }.to raise_error(
          NotImplementedError,
          "you must override this method when creating your own parser"
        )
      end
    end
  end
end
