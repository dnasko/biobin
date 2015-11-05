#!/usr/bin/env ruby
require 'getoptlong'

opts = GetoptLong.new(
                      ['--in', '-i', GetoptLong::REQUIRED_ARGUMENT],
                      ['--out', '-o', GetoptLong::REQUIRED_ARGUMENT],
                      [ '--help', '-h', GetoptLong::NO_ARGUMENT ],
)

infile = nil
out = nil
opts.each do |opt, arg|
  case opt
    when '--help'
      puts <<-EOF
Usage:
     skeleton.rb -in /Path/to/infile.fasta -out /Path/to/output.txt
                         [-help]

Options:
    -i, --in=FILENAME
       Input file in XXX format. (Required)

    -o, --out=FILENAME
       Output file in YYY format. (Required)
    
    -h, --help
       Displays the usage message. (Optional)

      EOF
    exit 0
    when '--in'
      infile = arg.to_s
    when '--out'
      out = arg.to_s
  end
end

if infile.nil?
  puts "\n\n ERROR! Required argument -in not found (try --help)\n\n"
  exit 0
end
if out.nil?
  puts "\n\n ERROR! Required argument -out not found (try --help)\n\n"
  exit 0
end

puts "Infile = " + infile
puts out

exit 0;
