#!/usr/bin/ruby

require 'json'

puts "Hello Ruby!"

INFO_PLIST_FILE = ENV['CODESIGNING_FOLDER_PATH'] + "/Info.plist"
# INFO_PLIST_FILE = ENV['SRCROOT'] + "/VideoApp/Info.plist"


puts INFO_PLIST_FILE

file = File.read('../Credentials/Credentials.json')

app_center_app_secret = JSON.parse(file)['app_center_app_secret']

text = File.read(INFO_PLIST_FILE)
replace = text.gsub("APP_CENTER_APP_SECRET_PLACEHOLDER", app_center_app_secret)
File.open(INFO_PLIST_FILE, "w") {|file| file.puts replace}

