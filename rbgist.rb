#!/usr/bin/env ruby

require 'net/https'
require 'cgi'
require 'json'
require 'optparse'

class Gist
  API_URL = URI.parse('https://api.github.com/')

  def initialize
    @user =  `git config --global github.user`
    @token = `git config --global github.token`.gsub(/(\r\n|\r|\n)/, "")
  end

  def htpps(request)
    https = Net::HTTP.new(API_URL.host, API_URL.port)
    https.use_ssl = true
    response = https.start do |http|
      http.request(request)
    end
  end

  def list_gists(options = {})
    req = Net::HTTP::Get.new("/gists?access_token=#{CGI.escape(@token)}")
    res = htpps req
    body = JSON.parse res.body

    body.each do |gist|
      print "id: "
      cprint "#{gist['id']}", :yellow
      puts " #{gist['description'] || gist['files'].keys.join(" ")} #{gist['public'] ? '' : '(secret)'}"

      unless options[:oneline]
        gist['files'].each do |file|
          puts "  * #{file[0]}"
        end
      end
    end
  end

  def cprint(str, clr)
    colors = {
      red: 31, green: 32, yellow: 33
    }
    print "\e[#{colors[clr].to_s}m"
    print str
    print "\e[0m"
  end
end

gist = Gist.new

options={}
OptionParser.new do |opt|
  opt.on('-l', '--list', 'list') {|v| options[:list] = v}
  opt.on('--oneline', 'oneline') {|v| options[:oneline] = v}

  opt.permute!(ARGV)
end

if options[:list]
  gist.list_gists options
end