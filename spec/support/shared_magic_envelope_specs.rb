# frozen_string_literal: true

shared_examples "a MagicEnvelope instance" do
  before do
    allow(DiasporaFederation.callbacks).to receive(:trigger).with(:fetch_public_key, sender).and_return(
      privkey.public_key
    )
  end

  it "is an instance of MagicEnvelope" do
    expect(subject).to be_an_instance_of DiasporaFederation::Salmon::MagicEnvelope
  end

  it "should match the sender" do
    expect(subject.sender).to eq(sender)
  end

  it "returns the entity" do
    entity = subject.payload
    expect(entity).to be_an_instance_of DiasporaFederation::Entities::TestEntity
    expect(entity.test).to eq(payload.test)
  end
end
