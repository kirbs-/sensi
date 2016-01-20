require "sensi/version"
require 'httparty'
require 'curb'
require 'json'
require 'cgi'

require 'sensi/account'
require 'sensi/thermostat'
require 'sensi/poll_response'

module Sensi

	class ThermostatConnection
  	include Sensi

  	attr_accessor :account, :thermostat_info, :response, :headers, :message_id, :first_poll_response, :groups_token

  	@response
  	@first_poll_response
  	@account
  	@thermostat_info
  	@message_id
  	@headers 
  	@groups_token

  	def initialize(account)
  		@account = account
  		@headers = {'Accept' => 'application/json; version=1, */*; q=0.01', 
  			'Content-Type' => 'application/x-www-form-urlencoded; charset=UTF-8', 
  			'Cookie' => @account.auth_cookie
  		}
  	end	

  	def get_info
  		@response = HTTParty.get(
  			Sensi::API_URI + '/api/thermostats',
  			headers: @account.headers
  			)
  		@thermostat_info = JSON.parse(@response.body)
  	end


    def set(device_id, setting, *args)
      setting_args = [device_id]
      args.each do |arg|
        setting_args.push(arg)
      end

      response = HTTParty.post(
        Sensi::API_URI + '/realtime/send',
        query: {transport: 'longPolling', connectionToken: @account.token},
        body: encode("{H: 'thermostat-v1', M: '#{setting}', A: #{setting_args}, I: 0}"), 
        headers: {"Cookie" => @account.auth_cookie}
        )
      #response
      response.code == 200
    end

  	def connect
  		response = HTTParty.get(
  			Sensi::API_URI + '/realtime/connect',
  			query: {transport: 'longPolling', 
          connectionToken: @account.token, 
          connectionData: '[{"name": "thermostat-v1"}]', 
          tid: 4, 
          _: (Time.now.to_f*1000).to_i},
  			headers: {"Cookie" => @account.auth_cookie}
  			)
  		@message_id = JSON.parse(response.body)['C']
  		response
  	end

  	# def initialize_polling(device_id)
  	# 	response = HTTParty.post(
  	# 		Sensi::API_URI + '/realtime/send',
  	# 		query: {transport: 'longPolling', connectionToken: @account.token},
  	# 		body: encode("{H: 'thermostat-v1', M: 'Subscribe', A:['#{device_id}'], I: 0}"), 
  	# 		headers: {"Cookie" => @account.auth_cookie}
  	# 		)
  	# 	response
  	# end

    def initialize_polling(device_id)
      set(device_id, 'Subscribe')
    end

  	def start_polling
  		@first_poll_response = HTTParty.get(
  			Sensi::API_URI + '/realtime/poll',
  			query: {transport: 'longPolling', 
          connectionToken: @account.token, 
          connectionData: '[{"name": "thermostat-v1"}]', 
          tid: 4, 
          _: (Time.now.to_f*1000).to_i, 
          messageId: @message_id},
  			headers: {"Cookie" => @account.auth_cookie}
  			)

      json = JSON.parse(@first_poll_response.body)
      poll_response = Sensi::PollResponse.new(json)
      @message_id = poll_response.message_id
      @groups_token = poll_response.groups_token
  		# json = JSON.parse(@first_poll_response.body)
  		# @message_id = json['C']
  		# @groups_token = json['G']
  		# @first_poll_response
      json
    rescue 
      json
  	end

  	def poll
  		response = HTTParty.get(
  			Sensi::API_URI + '/realtime/poll',
  			query: {transport: 'longPolling', 
  				connectionToken: @account.token, 
  				connectionData: '[{"name": "thermostat-v1"}]', 
  				tid: 4, 
  				_: (Time.now.to_f*1000).to_i, 
  				messageId: @message_id,
  				groupsToken: @groups_token},
  			headers: {"Cookie" => @account.auth_cookie}
  			)

      poll_response = Sensi::PollResponse.new(JSON.parse(response.body))
      @message_id = poll_response.message_id
  		# json = JSON.parse(response.body)
  		# @message_id = json['C']
  		poll_response
  	end

  	def stop_polling
  		response = HTTParty.post(
  			Sensi::API_URI + '/realtime/abort',
  			query: {transport: 'longPolling', connectionToken: @account.token},
  			body: '',
  			headers: {'Cookie' => @account.auth_cookie}
  			)
  	end


    private 

    def encode(text)
      "data=#{CGI.escape(text)}"
    end

  end
end