require 'rails_helper'
require 'generator_input'

RSpec.describe GeneratorInput, type: :model do
	
	
	# NOMINAL CASE
	params = {
			"generationMethod" => "Centroïd",
			"nbStations" => 15,
			"parkingRange_L" => 6,
			"parkingRange_U" => 10,
			"nbDemands" => 500,
			"timeStep" => 10,
			"areaLengthSide" => 100000,
			"averageCarSpeed" => 40,
			"maxTripDistance" => 60000,
			"centroidAreaDimension" => 10,
			"centroidDensity" => 35,
			"morningRushTimeSlot_L" => 7,
			"morningRushTimeSlot_U" => 9,
			"demandProportion_MR" => 80,
			"eveningRushTimeSlot_L" => 15,
			"eveningRushTimeSlot_U" => 19,
			"demandProportion_ER" => 60,
			"timePenalty" => 160,
			"demandDistrib_0" => 5,
			"demandDistrib_1" => 5,
			"demandDistrib_2" => 5,
			"demandDistrib_3" => 7,
			"demandDistrib_4" => 10,
			"demandDistrib_5" => 15,
			"demandDistrib_6" => 20,
			"demandDistrib_7" => 50,
			"demandDistrib_8" => 80,
			"demandDistrib_9" => 70,
			"demandDistrib_10" => 60,
			"demandDistrib_11" => 65,
			"demandDistrib_12" => 70,
			"demandDistrib_13" => 63,
			"demandDistrib_14" => 55,
			"demandDistrib_15" => 73,
			"demandDistrib_16" => 90,
			"demandDistrib_17" => 85,
			"demandDistrib_18" => 80,
			"demandDistrib_19" => 53,
			"demandDistrib_20" => 25,
			"demandDistrib_21" => 18,
			"demandDistrib_22" => 10,
			"demandDistrib_23" => 8
		}
		
		gen_inputs = GeneratorInput.new(params)
	
	it "has correct and valid attributes" do
		expect(gen_inputs).to have_attributes(:generationMethod => ('Centroïd' || 'Uniform'))
		expect(gen_inputs).to have_attributes(:nbStations => a_value)
	end
	
	
end
