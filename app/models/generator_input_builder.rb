require 'generator_input'

class GeneratorInputBuilder

# :generationMethod, :nbStations, :parkingRange_L, :parkingRange_U, :nbDemands,
# :timeStep, 

  def self.build
    builder = new
    yield(builder)
    builder.gen_inputs
  end

  def initialize
    @gen_inputs = GeneratorInput.new
  end

  def set_generation_method(gm)
    @gen_inputs.generation_method = gm
  end
  
  def set_nb_stations(nbs)
    @gen_inputs.nb_stations = nbs
  end

  def set_parking_ranges(pr_L, pr_U)
    @gen_inputs.parking_range_L = pr_L
    @gen_inputs.parking_range_U = pr_U
  end
  
  def set_nb_demands(nbd)
    @gen_inputs.nb_demands = nbd
  end

  def set_time_step(ts)
    @gen_inputs.time_step = ts
  end
  
  def set_area_lenght_side(als)
    @gen_inputs.area_lenght_side = als
  end
  
  def set_average_car_speed(acs)
    @gen_inputs.average_car_speed = acs
  end
  
  def set_max_trip_distance(mtd)
    @gen_inputs.max_trip_distance = mtd
  end
  
  def set_centroid_area_dimension(cad)
    @gen_inputs.centroid_area_dimension = cad
  end
  
  def set_centroid_density(cd)
    @gen_inputs.centroid_density = cd
  end
  
  def set_morning_rush_params(time_slot_L, time_slot_U, demand_proportion)
    @gen_inputs.morning_rush_time_slot_L = time_slot_L
    @gen_inputs.morning_rush_time_slot_U = time_slot_U
    @gen_inputs.morning_rush_demand_proportion = demand_proportion
  end
  
  def set_evening_rush_params(time_slot_L, time_slot_U, demand_proportion)
    @gen_inputs.evening_rush_time_slot_L = time_slot_L
    @gen_inputs.evening_rush_time_slot_U = time_slot_U
    @gen_inputs.evening_rush_demand_proportion = demand_proportion
  end
  
  def set_time_penalty(tp)
    @gen_inputs.time_penalty = tp
  end
  
  def set_demand(d)
    @gen_inputs.demand = d
  end

  def gen_inputs
    @gen_inputs
  end
  
  def self.build_default
    builder = self.new

    builder.set_generation_method('Centroïd')
    builder.set_nb_stations(15)    
    builder.set_parking_ranges(6, 10)
    builder.set_nb_demands(150)
    builder.set_time_step(10)
    builder.set_area_lenght_side(100000)
    builder.set_average_car_speed(40)
    builder.set_max_trip_distance(60000)
    builder.set_centroid_area_dimension(10)
    builder.set_centroid_density(35)
    builder.set_morning_rush_params(7, 9, 80)
    builder.set_evening_rush_params(15, 19, 60)
    builder.set_time_penalty(160)
    
    demand = [5, 5, 5, 7, 10, 15, 20, 50, 80, 70, 60, 65, 70, 63, 55, 73, 90, 85, 80, 53, 25, 18, 10, 8]
		builder.set_demand(demand)
    
    builder.gen_inputs
  end


end
