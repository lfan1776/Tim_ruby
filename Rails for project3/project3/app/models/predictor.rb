require './regressor.rb'

class Predictor
	def initialize
		if not (self.respond_to? :predict)
			throw Exception.new("need to implement predict method")
		end
	end

end

class TemperaturePredictor < Predictor
	def self.predict daily_data,latest_data,time
		
		daily_regress = BestRegressor.regress daily_data[0], daily_data[1]
		latest_regress = BestRegressor.regress latest_data[0], latest_data[1]
		daily_prediction = BestRegressor.calculate daily_regress, time
		latest_prediction = BestRegressor.calculate latest_regress, time
		if (latest_prediction - daily_prediction).abs <= ((1-daily_regress[1])*daily_prediction).abs
			return [latest_prediction,latest_regress[1]]
		else
			return [latest_prediction,((1-daily_regress[1])*daily_prediction).abs/(latest_prediction - daily_prediction).abs]
		end 


	end
end


