require 'rails_helper'

RSpec.describe Generator, type: :model do

  # NOMINAL CASE
  subject {described_class.new(GeneratorInputBuilder.build_default)}

  it "sould be valid when it's valid" do
    expect(subject).to be_valid
  end


end
