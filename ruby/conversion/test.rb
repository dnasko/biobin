#!/usr/bin/env ruby
require 'parse_fasta'

file=ARGV[0]

# puts " Getting ready to work on: #{file}"

FastaFile.open(ARGV.first, 'r').each_record do |header, sequence|
  puts ">#{header}\n#{sequence}"
end

exit 0
