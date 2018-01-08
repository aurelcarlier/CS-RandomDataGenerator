require 'cs_demand'
require 'cs_station'
require 'generator_input'
require 'nokogiri'

class Generator
					 
	def initialize(gen_inputs)
	
		@inputs = gen_inputs

		@demandList = Array.new
		@stationList = Array.new
		@stationList_insideCentroid = Array.new
		@stationList_outsideCentroid = Array.new
		
		# induced parameters
		@areaLengthSide = @inputs.areaLengthSide
		@centroidAreaDimension = @inputs.centroidAreaDimension
		
		@sideOfTheCentroidArea = Integer(@areaLengthSide * Math.sqrt(@centroidAreaDimension.to_f/100))
		@minInCentroid = Integer(@areaLengthSide/2) - Integer(@sideOfTheCentroidArea/2)
		@maxInCentroid = Integer(@areaLengthSide/2) + Integer(@sideOfTheCentroidArea/2)

		@nbTSInOneDay = 1440 / @inputs.timeStep
		@nbTSInOneHour = 60 / @inputs.timeStep
		@demand = @inputs.demand
		@demandOverTimeCumulatedAndNormalised = initDemand()
		@coefsTravelPenalty = init_coefsTravelPenalty
		
	end
	
	# Main generation method. Generates the random data (stations and demands)
	def generate
		generateStations
		generateDemands
	end
	
	# Generate stations over the urban area
	def generateStations
	
		case @inputs.generationMethod
		when "Centroïd"
	
			nbStationsInsideCentroid = Integer(@inputs.nbStations * (@inputs.centroidDensity.to_f/100))
		
			for idStation in (1..@inputs.nbStations)
			
				station = CS_station.new(idStation)
				
				station.insideCentroid = (idStation <= nbStationsInsideCentroid)
				station.maxSize = Random.rand(@inputs.parkingRange_L..@inputs.parkingRange_U)
		
				if(station.insideCentroid)
					station.xPos, station.yPos = generateCoords("inside")
					@stationList_insideCentroid.push(station)
				else
					station.xPos, station.yPos = generateCoords("outside")
					@stationList_outsideCentroid.push(station)
				end
				@stationList.push(station)
				
			end
		when "Uniform"
		else 
		end
	end
	
	# Generate demands over time among stations 
	def generateDemands
	
		case @inputs.generationMethod
		when "Centroïd"
		
			nbCreatedDemands = 1
			for idDemand in (1..@inputs.nbDemands)
				
				# Find a time
				rt = generateRandomTime
				
				# Find 2 stations for that time
				station_O, station_D = pickTwoStations(rt)
				
				# Demand creation
				travelTime = calculate_TravelTime_TS(station_O, station_D, rt)
				arrivalTime = (rt + travelTime) % @nbTSInOneDay 
				
				demandAlreadyExists = false
				@demandList.each do |d| # if the demand already exists, just increase its internal demand by 1
					if(d.sOrigin == station_O && d.sDestination == station_D && d.departureTime_TS == rt)
						d.increaseDemandBy(1)
						demandAlreadyExists = true
						break
					end
				end
				if(!demandAlreadyExists) # create a new demand if it does not exist
					@demandList.push(CS_demand.new(nbCreatedDemands, station_O, station_D, rt, arrivalTime))
					nbCreatedDemands += 1
				end
			end
		
		when "Uniform"
		else 
		end
	end
	
	
	# Initialize the coeficients for travel time penalties during rush hours
	def init_coefsTravelPenalty
		
		coefs = Hash.new
		for ts in 0..(@nbTSInOneDay-1)
			
			if isInPeriod("morning", ts) || isInPeriod("evening", ts)
				coefs[ts] = @inputs.timePenalty
			
			elsif isInPeriod("outsideRushPeriods", ts)
				coefs[ts] = 1.0
			end
			
		end
		return coefs
	end
	
	
	# Calculate and return the travel time (in number of time-steps)
	# to go from 'station_O' to 'station_D' at 'timeDeparture'
	def calculate_TravelTime_TS(station_O, station_D, timeDeparture)
		
		travelTime_TS = 0
		time_TS = timeDeparture

		traveledDistance = 0.0
		totalDistance = calculate_distanceBetweenStations(station_O, station_D)

		while (traveledDistance < totalDistance) do
			traveledDistance += (@inputs.averageCarSpeed * 1000 / @nbTSInOneHour) * (1 / @coefsTravelPenalty[time_TS])
			time_TS = (time_TS + 1) % @nbTSInOneDay
			travelTime_TS +=1
		end
		
		return travelTime_TS
	end
	
	
	# Pick and return two stations at the given time-step
	# 2 constraints of selection :
	# - rush period determines the orientation
	# - max distance ensures realistic demand
	def pickTwoStations(timeStep)
		
		station_O, station_D = nil, nil
		begin
			if isInPeriod("morning", timeStep)
				station_O = @stationList_outsideCentroid.sample
				station_D = @stationList_insideCentroid.sample
			
			elsif isInPeriod("evening", timeStep)
				station_O = @stationList_insideCentroid.sample
				station_D = @stationList_outsideCentroid.sample
			
			elsif isInPeriod("outsideRushPeriods", timeStep)
				list = @stationList.sample(2)
				station_O = list[0]
				station_D = list[1]
			end
		
		end while calculate_distanceBetweenStations(station_O, station_D) > @inputs.maxTripDistance
		return station_O, station_D
	end
	
	
	# Return the distance (in meters) between the two stations
	def calculate_distanceBetweenStations(stationOrigin, stationDestination)
		
		xO = Integer(stationOrigin.xPos)
		yO = Integer(stationOrigin.yPos)

		xD = Integer(stationDestination.xPos)
		yD = Integer(stationDestination.yPos)

		return Math.sqrt(((xD - xO)**2) + ((yD - yO)**2))
	end
	
	
	# Return true if 'timeStep' belongs to the given 'period' of the day
	# Possible values for 'period' are : "morning", "evening" and "outsideRushPeriods"  
	def isInPeriod(period, timeStep)
		
		mrts_l = convertHour2Ts(@inputs.morningRushTimeSlot_L)
		mrts_u = convertHour2Ts(@inputs.morningRushTimeSlot_U)
		erts_l = convertHour2Ts(@inputs.eveningRushTimeSlot_L)
		erts_u = convertHour2Ts(@inputs.eveningRushTimeSlot_U)
		
		case period
		when "morning"
			return (mrts_l <= timeStep) && (timeStep <= mrts_u)
		when "evening"
			return (erts_l <= timeStep) && (timeStep <= erts_u)
		when "outsideRushPeriods"
			return 	(0 <= timeStep && timeStep < mrts_l) || 			# before morning rush
					(mrts_u < timeStep && timeStep < erts_l) || 		# between morning and evening rushes
					(erts_u < timeStep && timeStep < @nbTSInOneDay)	# after evening rush
		end
	end
	
	# Convert an hour into a number of time-steps
	def convertHour2Ts(hour)
		return Integer(((hour * 60 ) * @nbTSInOneDay) / 1440);
	end
	
	
	# Generate and return a pair of coordinates inside or outside the centroid area
	def generateCoords(position)
		case position
		when "inside"
			xRandomValue = Random.rand(@minInCentroid..@maxInCentroid)
			yRandomValue = Random.rand(@minInCentroid..@maxInCentroid)
			return xRandomValue, yRandomValue
		when "outside"
			xlist = [Random.rand(0..@minInCentroid), Random.rand(@maxInCentroid..@areaLengthSide)]
			ylist = [Random.rand(0..@minInCentroid), Random.rand(@maxInCentroid..@areaLengthSide)]
			return xlist.sample, ylist.sample
		end
	end
	
	# Generate and return the XML file corresponding to the generated data (stations and demands)
	def generateXML
	
		builder = Nokogiri::XML::Builder.new do |xml|
  			xml.randomGeneratedData{
    			xml.parameters(:nbStations => @inputs.nbStations, :nbDemands => @inputs.nbDemands)
  				xml.stations{
  					@stationList.each do |s|
						xml.station(
							:id => s.id, 
							:xPos => s.xPos, 
							:yPos => s.yPos,
							:maxSize =>s.maxSize)
					end
  				}
  				xml.demands{
  					@demandList.each do |d|
  						xml.demand(
  							:id => d.id,
  							:idsOrigin => d.sOrigin.id, 
  							:idsDestination => d.sDestination.id, 
  							:nbDemand => d.nbDemand,
  							:departureTime => d.departureTime_TS,
  							:arrivalTime => d.arrivalTime_TS)
  					end
  				}
  			}
		end
		
		return builder.to_xml
	end
	
	
	# Return the demand value at the time-step given in parameter
	def getDemandAt(timeStep)
		index = Integer(timeStep / @nbTSInOneHour)
		return @demand[index]
	end
	
	# Initialize the demand distribution as a cumulated and normalized distribution
	def initDemand()
		
		# building the sum of the demand values
		sum_values = 0
		for ts in 0..(@nbTSInOneDay-1)
			sum_values += getDemandAt(ts)
		end
		
		# cululated sum + normalization 
		demand = Hash.new
		for ts in 0..(@nbTSInOneDay-1)
			if ts != 0
				demand[ts] = demand[ts-1] + (getDemandAt(ts).to_f / sum_values)
			else
				demand[ts] = getDemandAt(ts).to_f / sum_values
			end
		end
		
		return demand
	end
	
	
	# Pick and return a random time generated from the demand distribution
	def generateRandomTime
		
		randomValue = Random.rand(0.0..1.0)
		for ts in 0..(@nbTSInOneDay-1)
			if @demandOverTimeCumulatedAndNormalised[ts] >= randomValue
				return ts
			end
		end
	end
	
	

end
