require 'rubygems'
require 'pry'
require 'parser/current'
require 'rake'

Parser::Builders::Default.emit_lambda   = true
Parser::Builders::Default.emit_procarg0 = true
Parser::Builders::Default.emit_encoding = true
Parser::Builders::Default.emit_index    = true

usage = {}

file_list = FileList.new('./*/app/**/*.rb')
file_list.each do |file|
  parsed_code = Parser::CurrentRuby.parse(File.open(file).read)
  next if parsed_code.nil?
  def process(usage, part)
    if part.is_a?(Array)
      if part[0] == :send && part[-1].is_a?(Symbol)
        usage[part[-1]] ||= 0
        usage[part[-1]] +=1
      elsif part[0] == :send && part[1].nil? && part[2].is_a?(Symbol)
        usage[part[2]] ||= 0
        usage[part[2]] +=1
      end
      part.each do |e|
        process(usage, e)
      end
    else
    end
  end
  process(usage, parsed_code.to_sexp_array)
rescue Parser::SyntaxError
  next
end

usage.to_a.sort{|a, b| a[1] <=> b[1]}.each do |method, count|
  puts "#{method.to_s.ljust(30)} --- #{count}"
end

