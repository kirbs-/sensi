require "sensi/version"
require 'sensi/hash_to_object'
require 'sensi/thermostat_connection'
# require 'byebug'

module Sensi

	class Thermostat < HashToObject

		attr_accessor :account, :thermostat_connection, :response

		@account
		@thermostat_connection
		@response

		#private vars
		@mode
		@heat
		@cool
		@fan
		@schedule

		def initialize(login, password, json = nil)
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
				@response = @thermostat_connection.start_polling
				convert(@response)
				attempt += 1
			end

			connected_to_device?
		end

		def connected_to_device?
			self.m.respond_to?(:m)
		rescue
			false
		end

		def valid_response?
			# debugger
			@response.respond_to?(:m) and @response.m.class == Sensi::HashToObject
		rescue StandardError
			return false
		end

		def update(attempts = 3)
			@response = nil
			attempt = 0
			# debugger
			while attempt < attempts and not valid_response?
				@response = @thermostat_connection.poll
				attempt += 1
			end

			return false if @response.code != 200

			update_self(self, @response) if valid_response?
			!@response.timed_out? and valid_response?
		end

		def update_self(hto, response)
			datums = (response.methods - Object.new.methods).reject!{|i| i.to_s =~ /=|\?|convert|contains_hash|add|json|message_id|groups_token/ }
			datums.each do |data|
				# debugger
				if hto.respond_to?(data) and  hto.send(data).class == Sensi::PollResponse and response.send(data).class == Sensi::PollResponse
					update_self(hto.send(data), response.send(data))
				elsif hto.respond_to?(data) and  hto.send(data).class == Sensi::HashToObject and response.send(data).class == Sensi::HashToObject
					update_self(hto.send(data), response.send(data))
				elsif hto.respond_to?(data) and response.send(data).class == Sensi::PollResponse
					hto.send((data.to_s + '=').to_sym, response.send(data))
				else 
					hto.add_var(data.to_s, response.send(data))
				end
			end
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

		def system_fan
			self.m.a.environment_controls.fan_mode
		end

		def temperature(scale = :F)
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
			self.m.a.environment_controls.system_mode
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
					# puts "#{system_mode}:#{v.to_s.capitalize}"
					return update_system_mode v
				when :fan
					return update_fan v
				when :temp
					return update_temp v
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

		def system_active?
			active_mode != 'Off'
		end

		def system_temperature(type: nil)
			type = system_mode.downcase.to_sym if type.nil?

			case type
			when :heat
				return settings.heat_setpoint.f
			when :cool
				return settings.cool_setpoint.f
			else
				raise ArgumentError, "Type :#{type.to_s} not valid."
			end
		end

		# def system_heat_setpoint
		# 	settings.heat_setpoint
		# end

		# def system_cool_setpoint
		# 	settings.cool_setpoint
		# end

		def system_fan_on?
			system_fan == 'On'
		end

		def system_fan_off?
			system_fan == 'Auto'
		end

		def update_system_mode(state)
			if system_mode == state.to_s.capitalize
				return false
			else 
				result = @thermostat_connection.set(self.icd, 'SetSystemMode', state.to_s.capitalize)  
				update
				return result
			end
		end

		def update_fan(state)
			if system_fan == state.to_s.capitalize
				return false
			else
				result = @thermostat_connection.set(self.icd, 'SetFanMode', state.to_s.capitalize) 
				update
				return result
			end
			# case state
			# when 'On'
			# 	return @thermostat_connection.set(self.icd, 'SetFanMode', state.to_s.capitalize) unless system_fan_on?
			# when 'Auto'
			# 	return @thermostat_connection.set(self.icd, 'SetFanMode', state.to_s.capitalize) unless system_fan_off?
			# else
			# 	raise StandarError, "#{v} is not a valid fan state."
			# end
		end

		def update_temp(temperature, mode: nil, scale: :F)
			mode = system_mode if mode.nil?

			case mode
			when 'Heat'
				return true if system_temperature(type: :heat) == temperature
				result = @thermostat_connection.set(self.icd, 'SetHeat', temperature.to_s, scale.to_s.capitalize) 
			when 'Cool'
				return true if system_temperature(type: :cool) == temperature
				result = @thermostat_connection.set(self.icd, 'SetCool', temperature.to_s, scale.to_s.capitalize) 
			when 'Off'

			when 'Auto'

			when 'Aux'

			end
			update
			result
		end

		def to_json
        	hash = {}
	        self.instance_variables.each do |var|
	        	if var.is_a? HashToObject
	        		hash[var.to_s.delete("@")] = self.instance_variable_get var.to_json
	        	else
	            	hash[var.to_s.delete("@")] = self.instance_variable_get var
	            end
	        end
	        hash.to_json
	    end

	    def from_json!(string)
	        JSON.load(string).each do |var, val|
	            self.instance_variable_set var, val
	        end
	    end


  	end

end