#!/usr/bin/env ruby
# -*- coding:utf-8 -*-

require 'pit'
require 'json'
require 'net/http'
require 'net/https'

class URLTitle
  def initialize(url)
    @url = url
    @config = Pit.get("goo.gl", :require => { "key" => "Google API Key" });

    if /\Ahttps:/ =~ @url
      abort "https url '#{@url}' is not supported"
    end
  end

  def short_url
    api_url = URI.parse('https://www.googleapis.com/urlshortener/v1/url')

    https = Net::HTTP.new(api_url.host, api_url.port)
    https.verify_mode = OpenSSL::SSL::VERIFY_PEER
    https.use_ssl = true

    header = { 'Content-Type' => 'application/json' }
    req = Net::HTTP::Post.new(api_url.path, header)
    req.body = { key: @config['key'], longUrl: @url}.to_json

    response = https.start do |http|
      http.request(req)
    end

    JSON.parse(response.body)['id']
  end

  def title
    uri = URI.parse(@url)
    Net::HTTP.start(uri.host, uri.port) do |http|
      response = http.get(uri.path)

      str = response.body.encode('utf-8', 'iso-2022-jp')
      str.match(%r{<title[^>]*>([^<]+)</title>}i) do |matched|
        matched[1]
      end
    end
  end
end

url = ARGV[0]
abort "Usage #{$0} url" if url.nil?

agent = URLTitle.new(url)
print "#{agent.title} #{agent.short_url}"
