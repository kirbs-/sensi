require "sensi/version"
require 'json'

module Sensi

	class HashToObject

		# TEST = {'C': 'abc', 'A': ["hi", {:should=>"see"}], 'M': ['on','off','shutdown'], 'D': {'hola': 'hello'}, num: 5}

	  	def initialize(hash = TEST, debug = false, json = nil)
	      	convert(hash, debug)
	    end

	    def convert(obj, debug = false)
	    	obj.each do |obj|
	    		puts "#{obj}" if debug
	    		if obj.is_a? Array
	    			puts 'found array' if debug
	    			if obj.size == 2 and !obj[1].is_a? Hash and !obj[1].is_a? Array 
	    				puts 'found key/value' if debug
	    				add_var(obj[0].to_s, obj[1])
	    			elsif obj.size == 2 and obj[1].is_a? Hash
		    			puts 'found hash' if debug
		    			add_var(obj[0].to_s, HashToObject.new(obj[1]))
		    		elsif obj.size == 2 and obj[1].is_a? Array and contains_hash(obj[1])
		    			puts 'found array and contains hash' if debug
		    			add_var(obj[0].to_s, HashToObject.new(obj[1]))
		    		elsif obj.size == 2 and obj[1].is_a? Array
		    			puts 'found array and array' if debug
		    			add_var(obj[0].to_s, obj[1])
		    		elsif obj.size > 2
		    			puts 'found other' if debug
		    			obj.each do |item|
		    				add_var(k.to_s, HashToObject.new(item)) 
		    			end
		    		end
	    		elsif obj.is_a? Hash
	    			puts 'found hash 2' if debug
	    			obj.each do |k, v|
	    				if v.is_a? Array or v.is_a? Hash
	    					add_var(k.to_s, HashToObject.new(v))
	    				else 
	    					add_var(k.to_s,v)
	    				end
	    			end
			    end
		    end
	    end

	    def contains_hash(arr)
	    	arr.each do |item|
	    		return true if item.is_a? Hash
	    	end
	    	false
	    end

	    def add(k, v)
	    	self.instance_variable_set("@#{k.underscore}", v)
	        self.class.send(:define_method, k.underscore, proc{self.instance_variable_get("@#{k.underscore}")})
	        self.class.send(:define_method, "#{k.underscore}=", proc{|v| self.instance_variable_set("@#{k.underscore}", v)})
	    end

	    def add_var(k, v)
	    	(class << self; self; end).class_eval do
		    	# self.instance_variable_set("@#{k.underscore}", v)
		    	define_method( k.underscore, proc{ instance_variable_get("@#{k.underscore}") } )
		    	define_method( "#{k.underscore}=", proc{ |v| instance_variable_set("@#{k.underscore}", v) } )
	    	end
	    	self.instance_variable_set("@#{k.underscore}", v)
	    end

	    def to_json
        	hash = {}
	        self.instance_variables.each do |var|
	        	if var.is_a? HashToObject
	        		hash[var] = self.instance_variable_get(var).to_json
	        	else
	            	hash[var] = self.instance_variable_get(var)
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