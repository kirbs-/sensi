require "sensi/version"
require 'sensi/hash_to_object'

module Sensi

	class PollResponse < HashToObject

		attr_reader :json, :code

		def initialize(json)
			@json = json
			convert(json)
			@code = 200
		rescue
			@code = 500
		end

		def message_id
			self.c
		end

		def groups_token
			self.g
		rescue 
			nil
		end

		def timed_out?
			respond_to?(:t)
		end
  	end

end