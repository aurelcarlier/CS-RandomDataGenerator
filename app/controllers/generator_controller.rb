class GeneratorController < ApplicationController

	def generate
	
		gen_params = GeneratorInput.new(params[:gen])
		gen = Generator.new(gen_params)
		gen.generate
		@xml = gen.generateXML
		
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

	def init
	end

end
