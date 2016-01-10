require "sensi/version"
require 'httparty'
require 'curb'
require 'json'

module Sensi

  class Account
  	include Sensi

  	attr_accessor :token, :auth_response, :token_response, :headers, :cookie_hash, :auth_cookie

  	@auth_response
  	@token_response
  	@token
  	@username
  	@password
  	@cookie_hash
  	@auth_cookie
  	@headers

  	def initialize(username, password)
  		@username = username
  		@password = password
  		self
  	end

  	def login
  		authorize(@username, @password)
  		parse_cookies(@auth_response.get_fields('Set-Cookie'))
  		save_auth_cookie
  		add_auth_cookie_to_headers(@auth_cookie)
  		get_connection_token
  	end

  	def authorize(username, password)
  		@auth_response = HTTParty.post(
  			Sensi::API_URI + '/api/authorize', 
  			body: {UserName: username, Password: password}.to_json,
  			headers: {'Accept' => 'application/json; version=1, */*; q=0.01', 'X-Requested-With' => 'XMLHttpRequest', 'Content-Type' => 'application/json'}
  			)
  	end

  	def get_connection_token
  		@token_response = Curl.get(Sensi::API_URI + '/realtime/negotiate') do |req|
  			req.headers['Cookie'] = @auth_cookie
  			req.headers['Accept'] = 'application/json; version=1, */*; q=0.01'
  		end

  		@token = JSON.parse(@token_response.body)['ConnectionToken']
  		# @token_response = HTTParty.get(
  		# 	Sensi::API_URI + '/realtime/negotiate',
  		# 	headers: Sensi::DEFAULT_HEADERS
  		# 	)
  		# @token = @token_response['ConnectionToken']
  	end

  	def add_auth_cookie_to_headers(auth_cookie)
		@headers = {'Accept' => 'application/json; version=1, */*; q=0.01','Cookie' => auth_cookie}
  	end

  	def parse_cookies(response_cookies)
  		@cookie_hash = HTTParty::CookieHash.new
  		response_cookies.each do |cookie|
  			@cookie_hash.add_cookies(cookie)
  		end
  	end

  	def save_auth_cookie
  		@auth_cookie = @cookie_hash.to_cookie_string
  	end

  	def logout
  		HTTParty.delete(
  			Sensi::API_URI + '/api/authorize',
  			headers: {'Coookie' => @auth_cookie, 'Accept' => 'application/json; version=1, */*; q=0.01'}
  			)
  	end
  end
end