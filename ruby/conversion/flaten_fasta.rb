#!/usr/bin/env ruby
require 'getoptlong'
require 'parse_fasta'

## Copyright 2014 Daniel Nasko.
## License GPLv3+: GPU GPL version 3 or later <http://gnu.org/licenses/gpl.html>.
## This is free software: you are free to change and redistribute it.
## There is NO WARRENTY, to the extent permitted by law.
## 
## Please acknowledge author and affliliation in published work arising from thie script's
## usage <http://bioinformatics.udel.edu/Core/Acknowledge>.

opts = GetoptLong.new(
                      ['--in', '-i', GetoptLong::REQUIRED_ARGUMENT],
                      ['--out', '-o', GetoptLong::REQUIRED_ARGUMENT],
                      ['--help', '-h', GetoptLong::NO_ARGUMENT ],
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

 Flatens a FASTA file!

Options:
    -i, --in=FILENAME
       Input file in FASTA format. (Required)

    -o, --out=FILENAME
       Output file in FASTA format. (Required)
    
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

# output = File.open( "outputfile.yml","w" )
outfile = File.open( out,"w" )
FastaFile.open(ARGV.first, 'r').each_record do |header, sequence|
  outfile << ">#{header}\n#{sequence}"
end
outfile.close
exit 0;
