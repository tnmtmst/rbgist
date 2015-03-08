#!/usr/bin/env ruby

require 'net/https'
require 'cgi'
require 'json'

def cprint(str, clr)
  colors = {
    reset: 0, red: 31, green: 32, yellow: 33
  }
  print "\e[#{colors[clr].to_s}m"
  print str
  print "\e[#{colors[:reset].to_s}m"
end

USER =  `git config --global github.user`
TOKEN = `git config --global github.token`.gsub(/(\r\n|\r|\n)/, "")

url   = URI.parse('https://api.github.com/')

https = Net::HTTP.new(url.host, url.port)
https.use_ssl = true

req = Net::HTTP::Get.new("/gists?access_token=#{CGI.escape(TOKEN)}")
res = https.start do |http|
  http.request(req)
end

body = JSON.parse res.body

body.each do |gist|
  print "id: "
  cprint "#{gist['id']}", :yellow
  puts " #{gist['description'] || gist['files'].keys.join(" ")} #{gist['public'] ? '' : '(secret)'}"
  gist['files'].each do |file|
    puts "  * #{file[0]}"
  end
end