require_relative '../lib/sensi'

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
			@therm.set(fan: 'Auto').should be_truthy
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