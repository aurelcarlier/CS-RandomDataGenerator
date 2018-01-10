class GeneratorInput

  include ActiveModel::Validations
  
	attr_accessor :generation_method, :nb_stations, :parking_range_L, :parking_range_U,
	              :nb_demands, :time_step, :area_lenght_side, :average_car_speed,
	              :max_trip_distance, :centroid_area_dimension, :centroid_density, 
	              :morning_rush_time_slot_L, :morning_rush_time_slot_U,	:morning_rush_demand_proportion,
	              :evening_rush_time_slot_L, :evening_rush_time_slot_U, :evening_rush_demand_proportion,
	              :time_penalty, :demand

  validates :generation_method, presence: true, inclusion: { in: ['Centroïd', 'Uniform']}
  validates :nb_stations, numericality: { only_integer: true }, presence: true
  validates :parking_range_L, numericality: { only_integer: true }, presence: true
  validates :parking_range_U, numericality: { only_integer: true }, presence: true
  validates :nb_demands, numericality: { only_integer: true }, presence: true
  validates :time_step, numericality: { only_integer: true }, presence: true
  validates :area_lenght_side, numericality: { only_integer: true }, presence: true
  validates :average_car_speed, numericality: { only_integer: true }, presence: true
  validates :max_trip_distance, numericality: { only_integer: true }, presence: true
  validates :centroid_area_dimension, numericality: { only_integer: true }, presence: true
  validates :centroid_density, numericality: { only_integer: true }, presence: true
  validates :morning_rush_time_slot_L, numericality: { only_integer: true }, presence: true
  validates :morning_rush_time_slot_U, numericality: { only_integer: true }, presence: true
  validates :morning_rush_demand_proportion, numericality: { only_integer: true }, presence: true
  validates :evening_rush_time_slot_L, numericality: { only_integer: true }, presence: true
  validates :evening_rush_time_slot_U, numericality: { only_integer: true }, presence: true
  validates :evening_rush_demand_proportion, numericality: { only_integer: true }, presence: true
  validates :time_penalty, numericality: true, presence: true
  validate :validate_demand
  
  # Validates the demand inputs
  def validate_demand
    (0..23).each do |h|
      return false if @demand[h].nil?
    end
  end
  
  
end
