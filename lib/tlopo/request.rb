# frozen_string_literal: true

require 'net/http'
require 'logger'
require_relative 'request/version'

LOGGER ||= Logger.new $stderr

module Setters
  def make_setter(*names)
    names.each do |name|
      define_method(name) do |val|
        instance_variable_set("@#{name}", val)
        return self
      end
    end
  end
end

module Tlopo
  class Request
    extend Setters
    make_setter :url, :headers, :method, :payload

    def initialize
      @method = 'get'
      @insecure = false
      @http_trace = !ENV['HTTP_TRACE'].nil? && ENV['HTTP_TRACE'].downcase == 'true'
    end

    def run(&block)
      instance_eval(&block) if block_given?
      uri = URI(@url)
      is_https = uri.scheme == 'https'

      uri.path = '/' if uri.path.empty?

      path = uri.path

      unless uri.query.nil?
        path = uri.query.empty? ? uri.path : "#{uri.path}?#{uri.query}"
      end

      req = Object.const_get("Net::HTTP::#{@method.capitalize}").new(path)
      req.body = @payload

      @headers&.each { |k, v| req[k] = v }

      opts = {}

      opts[:use_ssl] = is_https
      opts[:verify_mode] = OpenSSL::SSL::VERIFY_NONE if is_https && @insecure

      Net::HTTP.start(uri.host, uri.port, opts) do |http|
        r = http.request(req)
        msg = "HTTP_TRACE - code: #{r.code} method: #{@method}, url: #{@url},"
        msg += " headers: #{@headers}, payload: #{@payload}"
        LOGGER.debug msg if @http_trace
        return r
      end
    end
  end
end
