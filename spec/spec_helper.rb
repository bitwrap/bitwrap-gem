require 'rubygems'
require 'bundler/setup'
require 'pipe/jruby'
require 'json'
require 'pp'

module Helpers
  def pipe_to_json(schema_path)
    p = Pipe::Jruby.new
    p.import("#{schema_path}.xml")
    File.open("#{schema_path}.json", 'w+') do |f|
      f << JSON.pretty_generate(p.to_graph)
    end
  end
end

RSpec.configure do |c|
  c.include Helpers
end

