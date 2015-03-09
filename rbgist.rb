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
      print "id: ", "#{gist['id']}".color(:yellow)
      puts " #{gist['description'] || gist['files'].keys.join(" ")} #{gist['public'] ? '' : '(secret)'}"


      unless options[:oneline]
        if options[:url]
          puts "  https: https://gist.github.com/#{gist['id']}.git"
          puts "  ssh  : git@gist.github.com:/#{gist['id']}.git"
        end

        gist['files'].each do |file|
          puts "  * #{file[0]}".color(:green)
        end
      end
    end
  end

  def show_gist(options = {})
    req = Net::HTTP::Get.new("/gists/#{options[:id]}?access_token=#{CGI.escape(@token)}")
    res = htpps req
    body = JSON.parse res.body

    unless options[:filename].nil?
      puts body['files'][options[:filename]]['content'].color(:green)
      return
    end

    puts "id: " + "#{body['id']}\n".color(:yellow)

    puts "Description"
    puts "  #{body['description'] || body['files'].keys.join(" ")} #{body['public'] ? '' : '(secret)'}".color(:green)

    print "\n"
    puts "Clone URL"
    puts "  https://gist.github.com/#{body['id']}.git".color(:green)
    puts "  git@gist.github.com:/#{body['id']}.git".color(:green)
    print "\n"

    puts "Files"
    body['files'].each do |filename, file|
      puts "  * #{filename}".color(:green)
      puts ">>>\n" + "#{file['content']}\n".color(:cyan) + "<<<\n\n" if options[:verbose]
    end
  end

  def create_gist(filenames, options={})
    req = Net::HTTP::Post.new("/gists?access_token=#{CGI.escape(@token)}")

    files = {}
    filenames.each do |filename|
      files[filename] = {
        filename: filename,
        content: File.read(filename)
      }
    end

    req.body = JSON.dump({
      description: options[:description] || '',
      public: !options[:private],
      files: files
    })
    res = htpps req

    if res.code == '201' # Created
      body = JSON.parse res.body

      puts "Success".color(:green)
      puts "https: https://gist.github.com/#{body['id']}.git"
      puts "ssh  : git@gist.github.com:/#{body['id']}.git"
    else
      puts "Failure".color(:red)
      puts res.body
    end
  end
end

class String
  FOREGROUND_COLORS = {
    black:   30,
    red:     31,
    green:   32,
    yellow:  33,
    blue:    34,
    magenta: 35,
    cyan:    36,
    white:   37
  }
  BACKGROUND_COLORS = {
    black:   40,
    red:     41,
    green:   42,
    yellow:  43,
    blue:    44,
    magenta: 45,
    cyan:    46,
    white:   47
  }

  def color(clr)
    "\e[#{FOREGROUND_COLORS[clr].to_s}m" + self + "\e[0m"
  end

  def background(clr)
    "\e[#{BACKGROUND_COLORS[clr].to_s}m" + self + "\e[0m"
  end
end

gist = Gist.new

options={}
OptionParser.new do |opt|
  opt.on('-l', '--list', 'List Gists') {|v| options[:list] = v}
  opt.on('--oneline', 'Display oneline') {|v| options[:oneline] = v}
  opt.on('-v' ,'--verbose', 'Verbose') {|v| options[:verbose] = v}

  opt.on('-i Gist_id', '--id Gist_id', 'Show Gists') {|v| options[:id] = v}
  opt.on('-f File_name', '--file File_name', 'File name in gist') {|v| options[:filename] = v}

  opt.on('-c', '--create', 'Create new Gist') {|v| options[:create] = v}
  opt.on('--private', 'Private Gist') {|v| options[:private] = v}
  opt.on('-d DESC', '--description DESC', 'Description for Gist')  {|v| options[:description] = v}

  opt.permute!(ARGV)
end

if ARGV.empty? # No args
  if options[:list]
    gist.list_gists options if     options[:id].nil?
    gist.show_gist options  unless options[:id].nil?
  end

  puts "Require file select for create Gist !".color(:red) if options[:create]
else # Exist args
  if options[:create]
    filenames = []
    ARGV.each do |arg|
      filenames << arg
    end
    gist.create_gist filenames, options
  end
end

