require_relative '../lib/sensi'
require 'json'

RSpec.describe 'Sensi::Thermostat' do

	before :each do
		@therm = Sensi::Thermostat.new('someuser','somepw')
		@therm.stub(:icd).and_return('123')
	end

	describe '#system_fan_on?' do
		it 'returns false if fan is set to auto' do 
			# therm = Sensi::Thermostat.new('abc','123')
			allow(@therm).to receive(:system_fan).and_return('Auto')
			@therm.system_fan_on?.should be_falsey
		end

		it 'return true if fan is set to on' do 
			allow(@therm).to receive(:system_fan).and_return('On')
			@therm.system_fan_on?.should be_truthy
		end
	end

	describe '#valid_response?' do
		before :each do
			@therm.response = double
		end

		it 'returns true if sensi returns valid json' do
			@therm.response.stub(:m).and_return(Sensi::PollResponse.new(JSON.parse('{"C":"0,def","M":[{"H":"thermostat-v1","M":"update","A":["00-00-00-00-00-00-00-00",{"EnvironmentControls":{"FanMode":"On"},"OperationalStatus":{"BatteryVoltage":31,"Running":{"Mode":"Off"},"LowPower":false,"ScheduleTemps":{"AutoHeat":{"F":62,"C":17},"AutoCool":{"F":83,"C":28},"Heat":{"F":70,"C":21},"Cool":{"F":83,"C":28}}},"Schedule":{"Projection":[{"Day":"5/8/2016","ProjectionType":"Schedule","Time":"09:20:43","Heat":{"F":70,"C":21}},{"Day":"5/8/2016","ProjectionType":"Schedule","Time":"17:00:00","Heat":{"F":70,"C":21}},{"Day":"5/8/2016","ProjectionType":"Schedule","Time":"21:00:00","Heat":{"F":68,"C":20}},{"Day":"5/9/2016","ProjectionType":"Schedule","Time":"06:00:00","Heat":{"F":70,"C":21}}]}}]}]}')))
			@therm.valid_response?.should be_truthy
		end

		it 'returns false if sensi returns invalid json' do
			@therm.response.stub(:m).and_return([])
			@therm.valid_response?.should be_falsey
		end


	end

	describe '#set' do
		before :each do
			@therm.thermostat_connection = double
			allow(@therm.thermostat_connection).to receive(:set).with(anything, anything, anything).and_return(true)
			@therm.stub(:update)
		end

		it 'sets mode to cool' do
			@therm.stub(:system_mode).and_return('Heat')
			@therm.set(mode: 'Cool').should be_truthy
		end

		it 'sets mode to heat' do
			@therm.stub(:system_mode).and_return('cool')
			@therm.set(mode: 'Heat').should be_truthy
		end

		it 'does nothing when set to heat and heat is already on' do
			@therm.stub(:system_mode).and_return('Heat')
			@therm.set(mode: 'Heat').should be_falsey
		end

		it 'sets mode to off' do
			@therm.stub(:system_mode).and_return('cool')
			@therm.set(mode: 'Off').should be_truthy
		end

		it 'sets fan on' do
			@therm.stub(:system_fan).and_return('Auto')
			@therm.set(fan: 'On').should be_truthy
		end

		it 'sets fan to auto' do
			@therm.stub(:system_fan).and_return('On')
			@therm.thermostat_connection.stub(:poll).and_return(Sensi::PollResponse.new(JSON.parse('{"C":"0,529705F439B6F","M":[{"H":"thermostat-v1","M":"update","A":["36-6f-92-ff-fe-03-90-77",{"EnvironmentControls":{"FanMode":"Auto"},"OperationalStatus":{"BatteryVoltage":31,"Running":{"Mode":"Off"},"LowPower":false,"ScheduleTemps":{"AutoHeat":{"F":62,"C":17},"AutoCool":{"F":83,"C":28},"Heat":{"F":70,"C":21},"Cool":{"F":83,"C":28}}},"Schedule":{"Projection":[{"Day":"5/8/2016","ProjectionType":"Schedule","Time":"09:20:43","Heat":{"F":70,"C":21}},{"Day":"5/8/2016","ProjectionType":"Schedule","Time":"17:00:00","Heat":{"F":70,"C":21}},{"Day":"5/8/2016","ProjectionType":"Schedule","Time":"21:00:00","Heat":{"F":68,"C":20}},{"Day":"5/9/2016","ProjectionType":"Schedule","Time":"06:00:00","Heat":{"F":70,"C":21}}]}}]}]}')))
			@therm.set(fan: 'Auto').should be_truthy
			@therm.system_fan.should eq('Auto')
		end
	end

	describe ' - FAN - ' do
		before :each do
			@therm.thermostat_connection = double
			allow(@therm.thermostat_connection).to receive(:set).with(anything, anything, anything).and_return(true)
			@therm.stub(:update).and_return(true)
		end

		describe 'when fan is on' do

			it 'does nothing when set to on' do
				@therm.stub(:system_fan).and_return('On')
				@therm.update_fan('On').should be_falsey
			end

			it 'turns off when set to auto' do 
				@therm.stub(:system_fan).and_return('On')
				@therm.update_fan('Auto').should be_truthy
			end
		end

		describe 'when fan is off' do

			it 'turn on when set to on' do
				@therm.stub(:system_fan).and_return('Auto')
				@therm.update_fan('On').should be_truthy
			end

			it 'does nothing when set of auto' do
				@therm.stub(:system_fan).and_return('Auto')
				@therm.update_fan('Auto').should be_falsey
			end
		end
		
		it 'raises an error if parameter is not "On" or "Auto"' do
			expect{@therm.update_fan('Off')}.to raise_error
		end
	end

	describe ' - MODE - ' do
		it 'turns off' do
			# pending
		end

		it 'turns heat on' do
			# pending
		end

		it 'turns a/c on' do
			# pending
		end

		it 'turns auto on' do
			# pending
		end
	end

end