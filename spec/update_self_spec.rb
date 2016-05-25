require_relative '../lib/sensi'
require 'json'

RSpec.describe 'Sensi::HashToObject' do

	before :each do
		@therm = Sensi::Thermostat.new('123', '456')
	end

	describe 'update from simple response' do
		before :each do
			simple_response = {'hi':'hello', 'temp': 0, 'day': {'m': 0, 't': 1}}
			@therm.convert(simple_response)
		end

		# it 'updates self if one level deep' do
		# 	@hto = Sensi::HashToObject.new({'hi':'hola', 'temp': 75})
		# 	@therm.update_self(@therm, @hto)
		# 	@therm.hi.should eq('hola')
		# 	@therm.temp.should_not eq(0)
		# end

		# it 'updates self if two levels deep' do
		# 	@hto = Sensi::HashToObject.new({'hi':'hola', 'temp': 75, 'day': {'m': 7, 't': 8}})
		# 	@therm.update_self(@therm, @hto)
		# 	@therm.hi.should eq('hola')
		# 	@therm.temp.should_not eq(0)
		# 	@therm.day.m.should eq(7)
		# end

		# it 'adds new methods from response' do
		# 	@hto = Sensi::HashToObject.new({'hi':'hola', 'temp': 75, 'day': {'m': 7, 't': 8}, 'wonder': 'bread'})
		# 	@therm.update_self(@therm, @hto)
		# 	@therm.wonder.should eq('bread')
		# end

		it 'only updates necessary attributes' do
			@hto = Sensi::PollResponse.new({'temp': 75, 'day': 'tues', 'wonder': 'bread'})
			@therm.update_self(@therm, @hto)
			@therm.hi.should eq('hello')
			@therm.wonder.should eq('bread')
			@therm.day.m.should eq 0
		end
	end

	describe 'update from full response' do
		before :each do
			initial_signin = JSON.parse('{"C":"0,abc","G":"abc","M":[{"H":"thermostat-v1","M":"online","A":["00-00-00-00-00-00-00-00",{"Capabilities":{"TemperatureOffset":{"Min":-5,"Max":5},"SystemModes":["Off","Heat","Cool","Aux","Auto"],"Scheduling":{"MaxStepsPerDay":8,"SeparateDaysPerWeek":7},"HumidityOffset":{"Min":-25,"Max":25},"HumidityDisplay":true,"HeatLimits":{"Min":{"F":45,"C":7},"Max":{"F":99,"C":37}},"CoolLimits":{"Min":{"F":45,"C":7},"Max":{"F":99,"C":37}},"HeatCycleRates":["Slow","Medium","Fast"],"CoolCycleRates":["Slow","Medium","Fast"],"AuxCycleRates":["Slow","Medium","Fast"],"HoldModes":["Off","Temporary"],"IndoorEquipment":"Electric","IndoorStages":1,"OutdoorEquipment":"HeatPump","OutdoorStages":1},"EnvironmentControls":{"CoolSetpoint":{"F":83,"C":28},"HeatSetpoint":{"F":70,"C":21},"FanMode":"Auto","SystemMode":"Heat","ScheduleMode":"On","HoldMode":"Off"},"OperationalStatus":{"Temperature":{"F":70,"C":21},"Humidity":65,"BatteryVoltage":31,"Running":{"Mode":"Off"},"LowPower":false,"OperatingMode":"Heat","ScheduleTemps":{"AutoHeat":{"F":62,"C":17},"AutoCool":{"F":83,"C":28},"Heat":{"F":70,"C":21},"Cool":{"F":83,"C":28}}},"Schedule":{"Schedules":[{"ObjectId":"00000000-0000-0000-0000-000000000000","Name":"Cool","Type":"Cool","Daily":[{"Days":["Monday","Tuesday","Wednesday","Thursday","Friday"],"Steps":[{"Time":"06:00:00","Cool":{"F":75,"C":24}},{"Time":"08:00:00","Cool":{"F":83,"C":28}},{"Time":"17:00:00","Cool":{"F":75,"C":24}},{"Time":"22:00:00","Cool":{"F":78,"C":26}}]},{"Days":["Saturday","Sunday"],"Steps":[{"Time":"06:00:00","Cool":{"F":75,"C":24}},{"Time":"08:00:00","Cool":{"F":83,"C":28}},{"Time":"17:00:00","Cool":{"F":75,"C":24}},{"Time":"22:00:00","Cool":{"F":78,"C":26}}]}]},{"ObjectId":"00000000-0000-0000-0000-000000000000","Name":"Auto","Type":"Auto","Daily":[{"Days":["Monday","Tuesday","Wednesday","Thursday","Friday"],"Steps":[{"Time":"06:00:00","Heat":{"F":70,"C":21},"Cool":{"F":75,"C":24}},{"Time":"08:00:00","Heat":{"F":62,"C":17},"Cool":{"F":83,"C":28}},{"Time":"17:00:00","Heat":{"F":70,"C":21},"Cool":{"F":75,"C":24}},{"Time":"22:00:00","Heat":{"F":62,"C":17},"Cool":{"F":78,"C":26}}]},{"Days":["Saturday","Sunday"],"Steps":[{"Time":"06:00:00","Heat":{"F":70,"C":21},"Cool":{"F":75,"C":24}},{"Time":"08:00:00","Heat":{"F":62,"C":17},"Cool":{"F":83,"C":28}},{"Time":"17:00:00","Heat":{"F":70,"C":21},"Cool":{"F":75,"C":24}},{"Time":"22:00:00","Heat":{"F":62,"C":17},"Cool":{"F":78,"C":26}}]}]},{"ObjectId":"00000000-0000-0000-0000-000000000000","Name":"Heat","Type":"Heat","Daily":[{"Days":["Tuesday","Thursday","Friday"],"Steps":[{"Time":"06:00:00","Heat":{"F":70,"C":21}},{"Time":"08:00:00","Heat":{"F":66,"C":19}},{"Time":"16:30:00","Heat":{"F":70,"C":21}},{"Time":"21:00:00","Heat":{"F":68,"C":20}}]},{"Days":["Saturday","Sunday"],"Steps":[{"Time":"07:30:00","Heat":{"F":70,"C":21}},{"Time":"17:00:00","Heat":{"F":70,"C":21}},{"Time":"21:00:00","Heat":{"F":68,"C":20}}]},{"Days":["Monday","Wednesday"],"Steps":[{"Time":"06:00:00","Heat":{"F":70,"C":21}},{"Time":"10:00:00","Heat":{"F":66,"C":19}},{"Time":"17:00:00","Heat":{"F":70,"C":21}},{"Time":"21:00:00","Heat":{"F":68,"C":20}}]}]}],"Active":{"Heat":"00000000-0000-0000-0000-000000000000","Cool":"00000000-0000-0000-0000-000000000000","Auto":"00000000-0000-0000-0000-000000000000","Running":"00000000-0000-0000-0000-000000000000"},"Projection":[{"Day":"5/8/2016","ProjectionType":"Schedule","Time":"09:23:27","Heat":{"F":70,"C":21}},{"Day":"5/8/2016","ProjectionType":"Schedule","Time":"17:00:00","Heat":{"F":70,"C":21}},{"Day":"5/8/2016","ProjectionType":"Schedule","Time":"21:00:00","Heat":{"F":68,"C":20}},{"Day":"5/9/2016","ProjectionType":"Schedule","Time":"06:00:00","Heat":{"F":70,"C":21}}]},"Settings":{"Degrees":"F","TemperatureOffset":0,"ComfortRecovery":"Off","FastSecondStageHeat":"On","CompressorLockout":"On","LocalTimeDisplay":"On","KeypadLockout":"Off","ContinuousBacklight":"Off","LocalHumidityDisplay":"On","HumidityOffset":0,"HeatCycleRate":"Medium","CoolCycleRate":"Medium","AuxCycleRate":"Medium","AutoModeDeadband":2},"Product":{"MacAddress":"0","Firmware":{"Bootloader":"6003970904","Thermostat":"6003980910","Wireless":"2124B208"},"ModelNumber":"UP500WB1"}}]}]}')
			@therm.convert(initial_signin)
			fan_response = Sensi::PollResponse.new(JSON.parse('{"C":"0,def","M":[{"H":"thermostat-v1","M":"update","A":["00-00-00-00-00-00-00-00",{"EnvironmentControls":{"FanMode":"On"},"OperationalStatus":{"BatteryVoltage":31,"Running":{"Mode":"Off"},"LowPower":false,"ScheduleTemps":{"AutoHeat":{"F":62,"C":17},"AutoCool":{"F":83,"C":28},"Heat":{"F":70,"C":21},"Cool":{"F":83,"C":28}}},"Schedule":{"Projection":[{"Day":"5/8/2016","ProjectionType":"Schedule","Time":"09:20:43","Heat":{"F":70,"C":21}},{"Day":"5/8/2016","ProjectionType":"Schedule","Time":"17:00:00","Heat":{"F":70,"C":21}},{"Day":"5/8/2016","ProjectionType":"Schedule","Time":"21:00:00","Heat":{"F":68,"C":20}},{"Day":"5/9/2016","ProjectionType":"Schedule","Time":"06:00:00","Heat":{"F":70,"C":21}}]}}]}]}'))
			@therm.update_self(@therm, fan_response)
		end

		# it 'updates self one level deep' do
		# 	@therm.system_fan.should eq('On')
		# end

		# it 'only updates necessary attributes' do 
		# 	@therm.settings.cool_setpoint.f.should eq(83)
		# end

		# it 'doesn\'t change the system mode' do
		# 	@therm.system_mode.should eq 'Heat'
		# end
	end

end