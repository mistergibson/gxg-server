#!/usr/bin/env jruby
require(::File.expand_path((::File.dirname(__FILE__) << "/System/Libraries/gxg/gxg/bootstrap.rb")))
puts "Found Environment: #{::GxG::BOOTSTRAP[:environment].inspect}"
# Platform Deps for native Gem builds:
if [:ubuntu, :debian, :mint, :linux, :linuxmint].include?(::GxG::BOOTSTRAP[:environment])
  if RUBY_ENGINE == "jruby"
    system("sudo apt-get install libpostgresql-jdbc-java libzmq5 libzmq3-dev")
  else
    system("sudo apt-get install build-essential libssl-dev ruby2.5-dev libsqlite3-dev libmysqlclient-dev libpq-dev libzmq5 libzmq3-dev")
  end
end
system("sudo jgem install #{(::File.dirname(__FILE__) << "/seeds/gxg-framework-current.gem")}")
if RUBY_ENGINE == "jruby"
  # Load base requirements: 
  requirements = []
  requirements.push({:requirement => "spoon", :gem => "spoon"})
  requirements.push({:requirement => "psych", :gem => "psych"})
  requirements.push({:requirement => "sinatra", :gem => "sinatra"})
  requirements.push({:requirement => "sinatra-contrib", :gem => "sinatra-contrib"})
  requirements.push({:requirement => "webrocket", :gem => "webrocket"})
  # Installation
  requirements.each do |the_record|
    if the_record[:gem]
      system("sudo jgem install #{the_record[:gem]}")
    end
  end
else
  # no-op
end

