#!/usr/bin/env ruby
require 'slack-ruby-client'
require 'json'
require 'net/http'

tokens = "";
File.open("token.json") do |file|
    tokens = JSON.load(file)
end

Slack.configure do |conf|
    conf.token=tokens['slack']
end

client=Slack::RealTime::Client.new
client.on :hello do
    puts "Sapphire get up now!"
end

client.on :message do |data|
    case data.text
    when ":atsumori:" then
        client.message channel: data.channel,text: "失礼しました熱盛と出てしまいました"
    when /^<@#{client.self.id}> ?\s(.+)$/m then
        messages=[]
        uri = URI.parse('https://www.cotogoto.ai/webapi/noby.json')
        https = Net::HTTP.new(uri.host, uri.port)
        coto = tokens['cotogoto']
        uri.query=URI.encode_www_form('persona'=>1,'ending'=>'にゃん','study'=>1,'lat'=>35.103480,'lng'=>137.148951,'appkey'=>tokens['cotogoto'],'text'=>$1)
        messages<<JSON.parse(Net::HTTP.get_response(uri).body)["text"]

        client.message channel: data.channel,text: messages.join("\n")
    end
end

client.on :close do |_data|
    puts 'see you'
    EM.stop
end

client.start!
