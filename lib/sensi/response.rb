require 'hash_to_object'

module Sensi

  class Response < HashToObject

  	def initialize(hash)
  		convert(hash)
  	end
  	
  end

end