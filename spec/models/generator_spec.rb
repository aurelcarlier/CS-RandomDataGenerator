require 'rails_helper'

RSpec.describe Generator, type: :model do

  # NOMINAL CASE
  subject {described_class.new(GeneratorInputBuilder.build_default) }
  
  context "when generating stations" do
    it "should generate the right number of stations" do
      subject.generate_stations
      expect(subject.inputs.nb_stations).to eq(subject.list_stations.size)
    end
    
  end
  
  context "when generating demands" do
    
    it "should generate the right number of demands" do
      subject.generate_data
      result = subject.list_demands.reduce(0) {|sum, cs_demand| sum += cs_demand.nbDemand}
      # result = subject.list_demands.map(&:nbDemand).reduce(:+)
      expect(subject.inputs.nb_demands).to eq(result)
    end
    
    it "should not exist a demand that have a distance > max_trip_distance" do
      subject.generate_data
      test_is_ok = false
      subject.list_demands.each do |cs_demand|
        dist = subject.calc_dist_between_stations(cs_demand.sOrigin, cs_demand.sDestination)
        test_is_ok = dist < subject.inputs.max_trip_distance ? true : false
        break unless test_is_ok 
      end
      expect(test_is_ok).to be_truthy
    end
  end


end
