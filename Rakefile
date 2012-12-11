require 'rubygems'
require 'bundler'
Bundler.require :default

require './lib/legco'
task :generate do
  data = Legco.members
  json = JSON.pretty_generate(data)
  File.open("legco_members.json", "w") do |f|
    f.write(json)
  end
end

task :default => :generate