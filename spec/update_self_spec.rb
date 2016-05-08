require_relative '../lib/sensi'

RSpec.describe 'Sensi::HashToObject' do

	before :each do
		@therm = Sensi::Thermostat.new('123', '456')
		@therm.convert({'hi':'hello', 'temp': 0, 'day': {'m': 0, 't': 1}})
	end

	describe 'update from response' do
		it 'updates self if one level deep' do
			@hto = Sensi::HashToObject.new({'hi':'hola', 'temp': 75})
			@therm.update_self(@therm, @hto)
			@therm.hi.should eq('hola')
			@therm.temp.should_not eq(0)
		end

		it 'updates self if two levels deep' do
			@hto = Sensi::HashToObject.new({'hi':'hola', 'temp': 75, 'day': {'m': 7, 't': 8}})
			@therm.update_self(@therm, @hto)
			@therm.hi.should eq('hola')
			@therm.temp.should_not eq(0)
			@therm.day.m.should eq(7)
		end
	end

end