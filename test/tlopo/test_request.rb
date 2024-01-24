# frozen_string_literal: true

require 'test_helper'
require 'json'

module Tlopo
  class TestRequest < Minitest::Test
    def test_that_it_has_a_version_number
      refute_nil ::Tlopo::Request::VERSION
    end

    def test_get_request
      url = 'https://postman-echo.com/get?foo=bar&bar=foo'
      r = Tlopo::Request.new.url(url).run
      assert r.code.to_i == 200

      # Check args
      r = JSON.parse(r.body)
      assert r['args']['foo'] == 'bar'
      assert r['args']['bar'] == 'foo'
    end

    def test_post_request
      url = 'https://postman-echo.com/post?foo=bar&bar=foo'
      payload = { 'foo' => 'bar', 'bar' => 'foo' }
      headers = { 'Content-Type': 'application/json' }

      r = Tlopo::Request.new.url(url).headers(headers).method('post').payload(payload.to_json).run
      assert r.code.to_i == 200

      # Check args
      r = JSON.parse(r.body)
      assert r['args']['foo'] == 'bar'
      assert r['args']['bar'] == 'foo'

      assert r['data'] == payload
    end

    def test_put_request_dsl
      url = 'https://postman-echo.com/put?foo=bar&bar=foo'
      payload = { 'foo' => 'bar', 'bar' => 'foo' }
      headers = { 'Content-Type': 'application/json' }

      r = Tlopo::Request.new.run do
        url url
        headers headers
        method 'put'
        payload payload.to_json
      end

      assert r.code.to_i == 200

      # Check args
      r = JSON.parse(r.body)
      assert r['args']['foo'] == 'bar'
      assert r['args']['bar'] == 'foo'

      assert r['data'] == payload
    end
  end
end
