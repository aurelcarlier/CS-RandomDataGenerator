class GeneratorController < ApplicationController

	def generate
	
	  inputs = build_gen_inputs_from_form
	  
	  # Build the generator
		gen = Generator.new(inputs)
		
		# Validate inputs
		# TODO
		
		gen.generate_data
		@xml = gen.generate_xml
		
		#d = gen.getDemandTest
		
		#render plain: gen.nbStationsInsideCentroid.inspect
		
		render :xml => @xml
			#[
			#gen.stationList.inspect,
			#gen.minInCentroid.inspect,
			#gen.maxInCentroid.inspect,
			#gen.areaLengthSide.inspect,
			#@xml.inspect
			#]
		
		#render plain: gen.demandOverTimeCumulatedAndNormalised.inspect
		
		#render 'generatedData'
		#render plain: params[:gen]["nbStations"].inspect
	end
	
	# Returns inputs build from the form values
	def build_gen_inputs_from_form
    inputs = GeneratorInputBuilder.build do |builder|
      form = params[:gen]
	    builder.set_generation_method(form["generation_method"].to_s)
	    builder.set_nb_stations(form["nb_stations"].to_i)    
      builder.set_parking_ranges(form["parking_range_L"].to_i, form["parking_range_U"].to_i)
      builder.set_nb_demands(form["nb_demands"].to_i)
      builder.set_time_step(form["time_step"].to_i)
      builder.set_area_lenght_side(form["area_lenght_side"].to_i)
      builder.set_average_car_speed(form["average_car_speed"].to_i)
      builder.set_max_trip_distance(form["max_trip_distance"].to_i)
      builder.set_centroid_area_dimension(form["centroid_area_dimension"].to_i)
      builder.set_centroid_density(form["centroid_density"].to_i)
      
      mrtsl = form["morning_rush_time_slot_L"].to_i
      mrtsu = form["morning_rush_time_slot_U"].to_i
      mrdp = form["morning_rush_demand_proportion"].to_i
      builder.set_morning_rush_params(mrtsl, mrtsu, mrdp)
      
      ertsl = form["evening_rush_time_slot_L"].to_i
      ertsu = form["evening_rush_time_slot_U"].to_i
      erdp = form["evening_rush_demand_proportion"].to_i
      builder.set_evening_rush_params(ertsl, ertsu, erdp)
      
      builder.set_time_penalty(form["time_penalty"].to_i)
    
      demand = []
      (0..23).each do |h|
        demand[h] = form["demand_distrib_".concat(h.to_s)].to_i
      end
		  builder.set_demand(demand)
	  end
	  
	  inputs
	end

	def init
	end

end
