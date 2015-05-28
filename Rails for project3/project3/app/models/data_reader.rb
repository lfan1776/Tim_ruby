require 'date'
require 'geo-distance'
GeoDistance.default_algorithm = :haversine

class DataReader
end

class WeatherReader < DataReader

	@station_list = Station.all
	#date_string = "2015-05-27"
	#p = PostCodeLocation.find_by(id: 1)
	#lat = p.lat
	#long = p.long

	def self.nearest_stations lat,long,start_date_string,end_date_string,latest_or_daily,number_of_stations
		#then find the nearest station for post_code
		start_date = Date.parse(start_date_string)
		end_date = Date.parse(end_date_string)

		lat_p = lat
		long_p = long
		dist_list = []
		@station_list.each do |s|
			name_s = s.name
			id_s = s.id
			lat_s = s.lat
			long_s = s.long
			dist_p_s = GeoDistance.distance( lat_p, long_p, lat_s, long_s ).km.number
			dist_struct = Struct.new(:id, :name, :dist_p_s)
			distance_s = dist_struct.new
			distance_s.id = id_s
			distance_s.name = s.name
			distance_s.dist_p_s = dist_p_s
			dist_list << distance_s
		end
		top_n_stations = dist_list.sort_by(&:dist_p_s)[0,number_of_stations]
		top_n_stations_readings = []
		if latest_or_daily == "latest"			
			top_n_stations.each do |top_n|
				station_readings = Station.find_by(name: top_n.name).latest_weather_readings.where(:created_at => (start_date.beginning_of_day..end_date.end_of_day))
				top_n_stations_readings << station_readings
			end	
		elsif latest_or_daily == "daily"
			top_n_stations.each do |top_n|
				station_readings = Station.find_by(name: top_n.name).daily_weather_readings.where(:created_at => (start_date.beginning_of_day..end_date.end_of_day))
				top_n_stations_readings << station_readings
			end
		end	
		return top_n_stations_readings
	end



	def self.locations
		#@station_list = [] 
		@station_list = Station.all
		#@station.each do |s|
		#	@station_list << s
		#end
		return @station_list

		#Station.find_by(id:1).latest_weather_readings.last


		#date = Date.parse("2015-05-27")
		#Station.where(:created_at => (date.beginning_of_day..date.end_of_day))
	end

	def self.location_id_date
		date = Date.parse("2015-05-27")
		station = Station.find_by(name: "mel")
		@location_id_date_list = station.latest_weather_readings.where(:created_at => (date.beginning_of_day..date.end_of_day))
		return @location_id_date_list
	end
	

	def self.post_code_date post_code,date_string
		#date = Date.parse(date_string)
		p = PostCodeLocation.find_by(id: post_code)
		lat_p = p.lat
		long_p = p.long
		top1_stations_readings = WeatherReader.nearest_stations(p.lat,p.long,date_string,date_string,"latest",1)
		return top1_stations_readings
	end

	def self.get_field_for_predition lat,long,start_date_string,end_date_string,latest_or_daily,field_name,number_of_stations
		#p = PostCodeLocation.find_by(ipost_code)
		#lat_p = p.lat
		#long_p = p.long 
		field_stations_array = []
		top_n_stations_latest_readings = WeatherReader.nearest_stations(lat,long,start_date_string,end_date_string,latest_or_daily,number_of_stations)
		top_n_stations_latest_readings.each do |topn_s|
			record_value_array = []
			topn_s.each do |station_r|
				if field_name == "temperature"
					t = station_r.temperature
					if (!t.nil?)
						record_value_array << t
					end
				elsif field_name == "wind_speed"
					ws = station_r.wind_speed
					if (!ws.nil?)
						record_value_array << ws
					end
				elsif field_name == "wind_direction"
					wd = station_r.wind_direction
					if (!wd.nil?)
						record_value_array << wd
					end
				elsif field_name == "rainfall"
					r = station_r.rainfall_mm_last_hour
					if (!r.nil?)
						record_value_array << r
					end 
				end
			end		
			field_stations_array <<	record_value_array
		end		
					 	 
		return field_stations_array
	end

end




