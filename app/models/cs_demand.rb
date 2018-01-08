class CS_demand

	attr_accessor :id, :sOrigin, :sDestination, :departureTime_TS, :arrivalTime_TS, :nbDemand

	def initialize(id, sOrigin, sDestination, departureTime_TS, arrivalTime_TS)
		@id = id
		@sOrigin = sOrigin
		@sDestination = sDestination
		@departureTime_TS = departureTime_TS
		@arrivalTime_TS = arrivalTime_TS
		@nbDemand = 1
	end
	
	# Increase the demand by the number given in parameter
	def increaseDemandBy(number)
		@nbDemand += number
	end
	
end


