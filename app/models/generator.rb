require 'cs_demand'
require 'cs_station'
require 'generator_input'
require 'nokogiri'

class Generator

  include ActiveModel::Validations
					 
	attr_accessor :inputs
	
	def initialize(gen_inputs)
	
		@inputs = gen_inputs

		@demandList = Array.new
		@stationList = Array.new
		@stationList_insideCentroid = Array.new
		@stationList_outsideCentroid = Array.new
		
		# induced parameters
		@areaLengthSide = @inputs.area_lenght_side
		@centroidAreaDimension = @inputs.centroid_area_dimension
		
		@sideOfTheCentroidArea = Integer(@areaLengthSide * Math.sqrt(@centroidAreaDimension.to_f/100))
		@minInCentroid = Integer(@areaLengthSide/2) - Integer(@sideOfTheCentroidArea/2)
		@maxInCentroid = Integer(@areaLengthSide/2) + Integer(@sideOfTheCentroidArea/2)

		@nbTSInOneDay = 1440 / @inputs.time_step
		@nbTSInOneHour = 60 / @inputs.time_step
		@demand = @inputs.demand
		@demandOverTimeCumulatedAndNormalised = init_demand
		@coefsTravelPenalty = init_coefsTravelPenalty
		
	end
	
	# Main generation method. Generates the random data (stations and demands)
	def generate_data
		generate_stations
		generate_demands
	end
	
	# Generate stations over the urban area
	def generate_stations
	
		case @inputs.generation_method
		when 'Centroïd'
	
			nbStationsInsideCentroid = Integer(@inputs.nb_stations * (@inputs.centroid_density.to_f / 100))
		
			(1..@inputs.nb_stations).each do |id|
			
				station = CS_station.new(id)
				
				station.insideCentroid = (id <= nbStationsInsideCentroid)
				station.maxSize = Random.rand(@inputs.parking_range_L..@inputs.parking_range_U)
		
				if(station.insideCentroid)
					station.xPos, station.yPos = generateCoords("inside")
					@stationList_insideCentroid.push(station)
				else
					station.xPos, station.yPos = generateCoords("outside")
					@stationList_outsideCentroid.push(station)
				end
				@stationList.push(station)
				
			end
		when 'Uniform'
		else 
		end
	end
	
	# Generate demands over time among stations 
	def generate_demands
	
		case @inputs.generation_method
		when 'Centroïd'
		
			nbCreatedDemands = 1
			(1..@inputs.nb_demands).each do |idDemand|
				
				# Find a time
				rt = generate_random_time
				
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
				unless(demandAlreadyExists) # create a new demand if it does not exist
					@demandList.push(CS_demand.new(nbCreatedDemands, station_O, station_D, rt, arrivalTime))
					nbCreatedDemands += 1
				end
			end
		
		when 'Uniform'
		else 
		end
	end
	
	
	# Initialize the coeficients for travel time penalties during rush hours
	def init_coefsTravelPenalty
		
		coefs = {}
		(0..(@nbTSInOneDay-1)).each do |ts|
			
			if is_in_period('morning', ts) || is_in_period('evening', ts)
				coefs[ts] = @inputs.time_penalty
			
			elsif is_in_period('outsideRushPeriods', ts)
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
		totalDistance = calc_dist_between_stations(station_O, station_D)

		while (traveledDistance < totalDistance)
			traveledDistance += (@inputs.average_car_speed * 1000 / @nbTSInOneHour) * (1 / @coefsTravelPenalty[time_TS])
			time_TS = (time_TS + 1) % @nbTSInOneDay 
			travelTime_TS += 1
		end
		
		return travelTime_TS
	end
	
	
	# Pick and return two stations at the given time-step
	# 2 constraints of selection :
	# - rush period determines the orientation
	# - max distance ensures realistic demand
	def pickTwoStations(timeStep)
		
		station_O, station_D = nil, nil
		loop do
			if is_in_period('morning', timeStep)
				station_O = @stationList_outsideCentroid.sample
				station_D = @stationList_insideCentroid.sample
			
			elsif is_in_period('evening', timeStep)
				station_O = @stationList_insideCentroid.sample
				station_D = @stationList_outsideCentroid.sample
			
			elsif is_in_period('outsideRushPeriods', timeStep)
				list = @stationList.sample(2)
				station_O = list[0]
				station_D = list[1]
			end

		  break unless calc_dist_between_stations(station_O, station_D) > @inputs.max_trip_distance
		end
		return station_O, station_D
	end
	
	
	# Return the distance (in meters) between the two stations
	def calc_dist_between_stations(stationOrigin, stationDestination)
		
		xO = Integer(stationOrigin.xPos)
		yO = Integer(stationOrigin.yPos)

		xD = Integer(stationDestination.xPos)
		yD = Integer(stationDestination.yPos)

		return Math.sqrt(((xD - xO)**2) + ((yD - yO)**2))
	end
	
	
	# Return true if 'timeStep' belongs to the given 'period' of the day
	# Possible values for 'period' are : 'morning', 'evening' and 'outsideRushPeriods'  
	def is_in_period(period, timeStep)
		
		mrts_l = convertHour2Ts(@inputs.morning_rush_time_slot_L)
		mrts_u = convertHour2Ts(@inputs.morning_rush_time_slot_U)
		erts_l = convertHour2Ts(@inputs.evening_rush_time_slot_L)
		erts_u = convertHour2Ts(@inputs.evening_rush_time_slot_U)
		
		case period
		when 'morning'
			return (mrts_l <= timeStep) && (timeStep <= mrts_u)
		when 'evening'
			return (erts_l <= timeStep) && (timeStep <= erts_u)
		when 'outsideRushPeriods'
			return 	(timeStep >= 0 && timeStep < mrts_l) ||     # before morning rush
					(timeStep > mrts_u && timeStep < erts_l) ||     # between morning and evening rushes
					(timeStep > erts_u && timeStep < @nbTSInOneDay) # after evening rush
		end
	end
	
	# Convert an hour into a number of time-steps
	def convertHour2Ts(hour)
		return Integer(((hour * 60 ) * @nbTSInOneDay) / 1440)
	end
	
	
	# Generate and return a pair of coordinates inside or outside the centroid area
	def generateCoords(position)
		case position
		when 'inside'
			xRandomValue = Random.rand(@minInCentroid..@maxInCentroid)
			yRandomValue = Random.rand(@minInCentroid..@maxInCentroid)
			return xRandomValue, yRandomValue
		when 'outside'
			xlist = [Random.rand(0..@minInCentroid), Random.rand(@maxInCentroid..@areaLengthSide)]
			ylist = [Random.rand(0..@minInCentroid), Random.rand(@maxInCentroid..@areaLengthSide)]
			return xlist.sample, ylist.sample
		end
	end
	
	# Generate and return the XML file corresponding to the generated data (stations and demands)
	def generate_xml
	
		builder = Nokogiri::XML::Builder.new do |xml|
  			xml.randomGeneratedData {
    			xml.parameters(nbStations: @inputs.nb_stations, nbDemands: @inputs.nb_demands)
          xml.stations {
            @stationList.each do |s|
							xml.station(
								id: s.id, 
								xPos: s.xPos, 
								yPos: s.yPos,
								maxSize: s.maxSize
							)
            end
          }
  				xml.demands {
            @demandList.each do |d|
  						xml.demand(
							  id: d.id,
								idsOrigin: d.sOrigin.id, 
								idsDestination: d.sDestination.id, 
								nbDemand: d.nbDemand,
								departureTime: d.departureTime_TS,
								arrivalTime: d.arrivalTime_TS
  						)
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
	def init_demand
		
		# building the sum of the demand values
		sum_values = 0
		(0..(@nbTSInOneDay - 1)).each do |ts|
			sum_values += getDemandAt(ts)
		end
		
		# cululated sum + normalization 
		demand = {}
		(0..(@nbTSInOneDay - 1)).each do |ts|
			demand[ts] =
			if ts != 0
				demand[ts - 1] + (getDemandAt(ts).to_f / sum_values)
			else
				getDemandAt(ts).to_f / sum_values
			end
		end
		
		return demand
	end
	
	
	# Pick and return a random time generated from the demand distribution
	def generate_random_time
		random_value = Random.rand(0.0..1.0)
		(0..(@nbTSInOneDay - 1)).each do |ts|
			return ts if @demandOverTimeCumulatedAndNormalised[ts] >= random_value
		end
	end
	
end
