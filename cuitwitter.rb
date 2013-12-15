# -*- coding: utf-8 -*-
require 'rubygems'
require 'twitter' # gem install twitter
require 'open-uri'
require 'kconv'

# 設定(ユーザが適切に設定して下さい)
CONSUMER_KEY = ""
CONSUMER_SECRET = ""
ACCESS_TOKEN = ""
ACCESS_TOKEN_SECRET = ""

WIDTH = 50
REPID = "LINELINELINELINELINELINELINELINELINELINELINELINELINELINELINE"
mode = ARGV.shift

#
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

def process(status)
  if !File.exist?("icons/#{status.user.id}.bmp")
    open("icons/#{status.user.id}", 'wb') do |output|
      open(status.user.profile_image_url) do |icon|
        output.write(icon.read)
      end
    end
    system("convert icons/#{status.user.id} +contrast -modulate 90 -depth 8 -colors 256 BMP3:icons/#{status.user.id}.bmp")
  end
  out = `./putStatus icons/#{status.user.id}.bmp`
  out.gsub!("#{REPID}0", "#{status.user.name}(#{status.user.screen_name})").gsub!("#{REPID}1","")
  messages = status.text.scan(/.{#{WIDTH}}|.+\Z/)
  0.upto(6) do |i|
    if i < messages.size
      out.gsub!("#{REPID}#{i+2}", messages[i].chomp)
    else
      out.gsub!("#{REPID}#{i+2}", "")
    end
  end
  out.gsub!("#{REPID}9", "#{status.created_at}")
  
  puts out
end


begin
  if mode == "streaming"
    client = Twitter::Streaming::Client.new do |config|
      config.consumer_key        = CONSUMER_KEY
      config.consumer_secret     = CONSUMER_SECRET
      config.access_token        = ACCESS_TOKEN
      config.access_token_secret = ACCESS_TOKEN_SECRET
    end
    client.user do |object|
      case object
      when Twitter::Tweet
        process(object)
      when Twitter::DirectMessage
        #puts "It's a direct message!"
      when Twitter::Streaming::StallWarning
        #warn "Falling behind!"
      end
    end
  else
    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = CONSUMER_KEY
      config.consumer_secret     = CONSUMER_SECRET
      config.access_token        = ACCESS_TOKEN
      config.access_token_secret = ACCESS_TOKEN_SECRET
    end
    client.home_timeline.each do |status|
      process(status)
    end
  end
rescue Twitter::Error
  puts "Error"
end
