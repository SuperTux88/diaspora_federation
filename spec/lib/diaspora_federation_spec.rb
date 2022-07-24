# frozen_string_literal: true

module DiasporaFederation
  describe DiasporaFederation do
    context "validate_config" do
      it "should validate the config" do
        expect(DiasporaFederation.callbacks).to receive(:definition_complete?).and_return(true)
        DiasporaFederation.validate_config
      end

      it "should fail if the server_uri is missing" do
        temp = DiasporaFederation.server_uri
        DiasporaFederation.server_uri = nil
        expect { DiasporaFederation.validate_config }.to raise_error(
          ConfigurationError,
          "server_uri: Missing or invalid"
        )
        DiasporaFederation.server_uri = temp
      end

      context "certificate_authorities", rails: true do
        before do
          @certificate_authorities = DiasporaFederation.certificate_authorities
        end

        it "allows certificate_authorities to be missing in test environment" do
          ::Rails.env = "test"
          DiasporaFederation.certificate_authorities = nil
          expect { DiasporaFederation.validate_config }.not_to raise_error
        end

        it "should fail in production if the certificate_authorities is missing" do
          ::Rails.env = "production"
          DiasporaFederation.certificate_authorities = nil
          expect { DiasporaFederation.validate_config }.to raise_error(
            ConfigurationError,
            "certificate_authorities: Not configured"
          )
        end

        it "should fail in production if the certificate_authorities file is missing" do
          ::Rails.env = "production"
          DiasporaFederation.certificate_authorities = "/unknown"
          expect { DiasporaFederation.validate_config }.to raise_error(
            ConfigurationError,
            "certificate_authorities: File not found: /unknown"
          )
        end

        after do
          DiasporaFederation.certificate_authorities = @certificate_authorities
          ::Rails.env = ENV.fetch("RAILS_ENV", "test")
        end
      end

      context "http configs" do
        it "should fail if the http_concurrency is not a number" do
          DiasporaFederation.http_concurrency = nil
          expect { DiasporaFederation.validate_config }.to raise_error(
            ConfigurationError,
            "http_concurrency: please configure a number"
          )
          DiasporaFederation.http_concurrency = 20
        end

        it "should fail if the http_timeout is not a number" do
          DiasporaFederation.http_timeout = nil
          expect { DiasporaFederation.validate_config }.to raise_error(
            ConfigurationError,
            "http_timeout: please configure a number"
          )
          DiasporaFederation.http_timeout = 30
        end

        it "should fail if the http_verbose is not a boolean" do
          DiasporaFederation.http_verbose = nil
          expect { DiasporaFederation.validate_config }.to raise_error(
            ConfigurationError,
            "http_verbose: please configure a boolean"
          )
          DiasporaFederation.http_verbose = false
        end
      end

      it "should validate the callbacks" do
        expect(DiasporaFederation.callbacks).to receive(:definition_complete?).and_return(false)
        expect { DiasporaFederation.validate_config }.to raise_error ConfigurationError, "Missing handlers for "
      end
    end
  end
end
