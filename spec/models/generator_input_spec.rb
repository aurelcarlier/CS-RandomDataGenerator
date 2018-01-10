require 'rails_helper'
require 'generator_input'

RSpec.describe GeneratorInput, type: :model do
	
	# NOMINAL CASE (using the default builder)
  subject {GeneratorInputBuilder.build_default}

  it "must be valid" do
    expect(subject).to be_valid
  end

  it "has to contains attribute generationMethod" do
    expect(subject).to have_attributes(:generation_method => ('Centroïd' || 'Uniform'))
  end

  it "must have integer value for the attribute nb_stations" do
    subject.nb_stations = "toto"
    expect(subject).to be_invalid
  end
	
	
end
