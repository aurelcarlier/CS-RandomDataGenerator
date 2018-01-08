

class GeneratorInput

	attr_accessor 	 :generationMethod,
					 :nbStations,
					 :parkingRange_L,
					 :parkingRange_U,
					 :nbDemands,
					 :timeStep,
					 :areaLengthSide,
					 :averageCarSpeed,
					 :maxTripDistance,
					 :centroidAreaDimension,
					 :centroidDensity,
					 :morningRushTimeSlot_L,
					 :morningRushTimeSlot_U,
					 :demandProportion_MR,
					 :eveningRushTimeSlot_L,
					 :eveningRushTimeSlot_U,
					 :demandProportion_ER,
					 :timePenalty,
					 :demand
					 
					 
	def initialize(params)
	
		# Integrity testing with string and integer parameters
		# strings:
		string_params = ["generationMethod"]
		for param in string_params do
			raise TypeError, 'Argument is not a String' unless params[param].is_a? String
		end
		
		# integers:
		integer_params = ["nbStations", "parkingRange_L", "parkingRange_U", "nbDemands", "timeStep", "areaLengthSide", "averageCarSpeed", "maxTripDistance", "centroidAreaDimension", "centroidDensity", "morningRushTimeSlot_L", "morningRushTimeSlot_U", "demandProportion_MR", "eveningRushTimeSlot_L", "eveningRushTimeSlot_U", "demandProportion_ER", "timePenalty"]
		for param in integer_params do
			raise TypeError, 'Argument is not an Integer' unless Integer(params[param]).is_a? Integer
		end
		
		# Variables setting
		@generationMethod = params["generationMethod"]
		
		@nbStations = params["nbStations"].to_i
		@parkingRange_L = params["parkingRange_L"].to_i
		@parkingRange_U = params["parkingRange_U"].to_i
		
		@nbDemands = params["nbDemands"].to_i
		
		@timeStep = params["timeStep"].to_i
		
		@areaLengthSide = params["areaLengthSide"].to_i
		@averageCarSpeed = params["averageCarSpeed"].to_i
		@maxTripDistance = params["maxTripDistance"].to_i
		@centroidAreaDimension = params["centroidAreaDimension"].to_i
		@centroidDensity = params["centroidDensity"].to_i
		
		@morningRushTimeSlot_L = params["morningRushTimeSlot_L"].to_i
		@morningRushTimeSlot_U = params["morningRushTimeSlot_U"].to_i
		@demandProportion_MR = params["demandProportion_MR"].to_i
		
		@eveningRushTimeSlot_L = params["eveningRushTimeSlot_L"].to_i
		@eveningRushTimeSlot_U = params["eveningRushTimeSlot_U"].to_i
		@demandProportion_ER = params["demandProportion_ER"].to_i
		
		@timePenalty = params["timePenalty"].to_f / 100
		
		@demand = init_demand(params)
		
	end
	
	# Build the demand from the parameters
	def init_demand(params)
		demand = Hash.new
		for i in 0..23
			demand[i] = Integer(params["demandDistrib_".concat(i.to_s)])
		end
		return demand
	end

end
