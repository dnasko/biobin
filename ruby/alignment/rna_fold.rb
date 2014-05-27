#!/usr/bin/ruby
require 'getoptlong'

opts = GetoptLong.new(
                      ['--fasta', '-f', GetoptLong::REQUIRED_ARGUMENT],
                      [ '--help', '-h', GetoptLong::NO_ARGUMENT ]
)

fasta = nil
opts.each do |opt, arg|
  case opt
    when '--help'
      puts <<-EOF
Usage:
     rna_fold.rb -fasta /Path/to/infile.fasta
                         [-help]

Options:
    -f, --fasta=FILENAME
       Input file in FASTA format. (Required)

    -h, --help
       Displays the usage message. (Optional)

      EOF
    exit 0
    when '--fasta'
      fasta = arg.to_s
  end
end

if fasta.nil?
  puts "\n\n ERROR! Required argument -fasta not found (try --help)\n\n"
  exit 0
end

bonds = {
  'GU' => 1,
  'UG' => 1,
  'AU' => 2,
  'UA' => 2,
  'CG' => 3,
  'GC' => 3
}

# bonds.each { |key, value|
#   puts "#{key} equals #{value}"
# }

class RNA
  def initialize(rna)
    @rna = rna
    return rna
  end
end

first = RNA.new("AUGC")

puts first

# File.open(fasta) do |file|
#   file.each do |line|
#     #puts line
#   end
# end

exit 0;
