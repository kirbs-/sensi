require "sensi/version"
require 'sensi/hash_to_object'
require 'sensi/thermostat_connection'

module Sensi

	class Thermostat < HashToObject

		attr_accessor :account, :thermostat_connection

		@account
		@thermostat_connection

		#private vars
		@mode
		@heat
		@cool
		@fan
		@schedule

		def initialize(login, password)
			@account = Sensi::Account.new(login, password)
			@thermostat_connection = Sensi::ThermostatConnection.new(@account)
		end

		def connect
			@account.login
			get_account_info
			connect_to_device
		end

		def disconnect
			@thermostat_connection.stop_polling
			@account.logout
		end

		def get_account_info
			convert(@thermostat_connection.get_info)
		end

		def connect_to_device(connection_attempt = 3)
			attempt = 1
			while not connected_to_device? and attempt < connection_attempt
				@thermostat_connection.connect
				@thermostat_connection.initialize_polling(self.icd)
				convert(@thermostat_connection.start_polling)
				attempt += 1
			end

			@heat = settings.heat_setpoint
			@cool = settings.cool_setpoint
			@mode = system_mode
			@schedule = nil
			@fan = 'Auto'

			return connected_to_device?
		end

		def connected_to_device?
			self.m.respond_to?(:m)
		rescue
			false
		end

		def update
			response = @thermostat_connection.poll
			self.m.a.operational_status = response.m.a.operational_status unless response.timed_out?
			!response.timed_out?
		end

		def system_modes
			self.m.a.capabilities.system_modes
		end

		def equipment
			self.m.a.capabilities.outdoor_equipment
		end	

		def settings
			self.m.a.environment_controls
		end

		def active_mode
			self.m.a.operational_status.running.mode
		end

		def active_time
			self.m.a.operational_status.running.time
		rescue 
			"0"
		end

		def temperature(scale: :F)
			case scale
			when :F
				return self.m.a.operational_status.temperature.f 
			when :C
				return self.m.a.operational_status.temperature.c
			else
				raise ArgumentError, "Scale #{scale} is not valid."
			end
		end

		def humidity
			self.m.a.operational_status.humidity
		end

		def system_mode
			self.m.a.operational_status.operating_mode
		end

		def system_fan
			nil
		end

		# def set(mode: nil, temp: 70, scale: :F, fan: :auto, schedule: :off)
		def set(args)
			# case mode
			# when :heat
			# 	@thermostat_connection.set(self.icd, 'SetSystemMode', mode.to_s.capitalize) unless system_mode == mode.to_s.capitalize
			# when :cool
			# 	@thermostat_connection.set(self.icd, 'SetSystemMode', mode.to_s.capitalize) unless system_cool_on?
			# end
			args.each do |k, v|
				case k
				when :mode
					@thermostat_connection.set(self.icd, 'SetSystemMode', v.to_s.capitalize) unless system_mode == mode.to_s.capitalize
				when :fan
					@thermostat_connection.set(self.icd, 'SetFanMode', v.to_s.capitalize) unless system_fan_on?
				when :temp
					@thermostat_connection.set(self.icd, 'SetHeat', v.to_s.capitalize, scale.to_s.capitalize) unless system_temperature(:heat) == temp

					@thermostat_connection.set(self.icd, 'SetCool', v.to_s.capitalize, scale.to_s.capitalize) unless system_temperature(:cool) == temp
				when :schedule
					@thermostat_connection.set(self.icd, 'SetScheduleMode', v.to_s.capitalize) unless system_schedule == args
				end
			end
		end

		# def mode(mode)
		# 	@thermostat_connection.set(self.icd, 'SetSystemMode', mode.to_s.capitalize)
		# end

		def heat_on?
			system_mode == 'Heat'
		end

		def cool_on?
			system_mode == 'Cool'
		end

		def aux_on?
			system_mode == 'Aux'
		end


		def system_on?
			system_mode != 'Off'
		end

		def system_off?
			system_mode == 'Off'
		end

		def system_heat_on?
			system_mode == 'Heat'
		end

		def system_cool_on?
			system_mode == 'Cool'
		end

		def system_aux_on?
			system_mode == 'Aux'
		end

		def system_auto_on?
			system_mode =- 'Auto'
		end

		def system_temperature(type)
			case type
			when :heat
				return settings.heat_setpoint.f
			when :cool
				return settings.cool_setpoint.f
			else
				raise ArgumentError, "Type #{type} not valid."
			end
		end

		# def system_heat_setpoint
		# 	settings.heat_setpoint
		# end

		# def system_cool_setpoint
		# 	settings.cool_setpoint
		# end

		def system_fan_on?
			nil
		end


  	end

end