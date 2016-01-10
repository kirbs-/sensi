require "sensi/version"
require 'sensi/hash_to_object'
require 'sensi/thermostat_connection'

module Sensi

	class Thermostat < HashToObject

		attr_accessor :account, :thermostat_connection

		@account
		@thermostat_connection

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
			return connected_to_device?
		end

		def connected_to_device?
			self.m.respond_to?(:m)
		rescue
			false
		end

		def update
			@thermostat_connection.poll
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

		def status
			self.m.a.operational_status.running.mode
		end

		def status_time
			self.m.a.operational_status.running.status.time
		rescue 
			"0"
		end

		def current_temperature(scale = "F")
			if scale == 'F'
				return self.m.a.operational_status.temperature.f 
			else
				return self.m.a.operational_status.temperature.c
			end
		end

		def current_humidity
			self.m.a.operational_status.humidity
		end

		def mode
			self.m.a.operational_status.operating_mode
		end

  	end

end