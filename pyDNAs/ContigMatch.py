#!/usr/bin/python

'''
Given a group of samples, each of which now has been separately assembled into contigs
	by velvet and stored in the "03-Assembly" folder within a subfolder named
	as /$ID-$Kmer/ containing the contigs.fa and contig-coverage.fa files . . . .
Then, this script will use a BLAT screen to identify the common contig sequences
	among the input group and generate the appropriate data tables and compiled
	fasta sequence file.
	
AGM 2011
'''

import re
import sys
import os
import time
import copy
import subprocess

#------------ USER VARIABLES -----------------
main    = '03-Assembly/'
grp     = 'Mus-A2'
Samplex = "MusA2a MusA2b"
#Samplex = "MusA1a MusA2a MusA2b MusB2a MusB2b MusC2a MusD2b"
kmer    = "21"
outdir  = '04-Quants'

#------------ GLOBAL VARIABLES --------------------
Seqs = {}
CommonID = []
CommonFasta = []
GenList = []
Samples = []
noder = re.compile("NODE_(\d+)")
if len(sys.argv) > 1:
	grp = sys.argv[1]
	kmer = sys.argv[2]
	for i in range(3,len(sys.argv)):
		Samples.append(sys.argv[i])
else:
	Samples = Samplex.split()

outdir = outdir+"/"+grp
if not os.path.isdir(outdir):
	os.mkdir(outdir)

class Ddict(dict):
    def __init__(self, default=None):
        self.default = default
    def __getitem__(self, key):
        if not self.has_key(key):
            self[key] = self.default()
        return dict.__getitem__(self, key)

# DataTable[GeneID][Sample] = contig node number in sample; NF= default, "not found"
DataTable = Ddict( lambda: Ddict( 'NF' ) )
	
def GeneID(id):
	n = len(id)
	for i in range (1,(7-n)):
		id = "0"+id
	return id

def ReadFasta(file,flag):
	FileFasta2 = open(file,'r')
	FileData = FileFasta2.readlines()
	FileFasta2.close()
	for line in FileData:
		headerline = re.match('>', line)
		if headerline is not None:
			line = re.sub('>','',line)
			nodenum = noder.match(line)
			header = flag + GeneID(nodenum.group(1))
			seq = ''
		else:
			seq = seq + line.rstrip()
			Seqs[header] = seq

def RevComp(seq): 
	basecomplement = {'A': 'T', 'C': 'G', 'G': 'C', 'T': 'A'} 
	seq = seq[::-1]
	seqnts = list(seq)
	seqnts = [basecomplement[base] for base in seqnts] 
	return ''.join(seqnts) 


for i in range(200000):
	inum = GeneID(str(i))
	for s in Samples:
		DataTable[inum][s] = 'NF'

#------------ M A I N  --------------------------------------

#str="TCTCCCCCAGCTGCTGGCAGGCCGGCTTCCTCCCGCGTGTCATTGGCACGCGACTCCCATGCCAGGCTGCTC"
#rc = RevComp(str)
#print rc
#sys.exit()

count = 911
commoncount = 1
xSamples = copy.deepcopy(Samples)
targ = Samples.pop(0)
print "\n\n-----------------------------------------------\nSCRIPT 09.1 - Comparing Samples:"
print "   >>> target =", targ
tfile = "%s%s-%s/contigs-afg.fa" % (main,targ,kmer)
for query in Samples:
	print "----------------------------------------"
	print "   >>> query  =", query
	qfile = "%s%s-%s/contigs-afg.fa" % (main,query,kmer)
	bout = "%s/00-blatout-%d.psl" % (outdir, count)
	blatcmd = ['blat', '-minIdentity=96', '%s' % tfile, '%s' % qfile, '%s' % bout]   # '-noHead', 
	blatter = subprocess.Popen(blatcmd)
	blatter.wait()
	
	# Input FASTA files . . . .
	GenList[:] = []
	Seqs.clear()
	ReadFasta(tfile,'')
	ReadFasta(qfile,"Q")
	# Open the BLAT output file . . .
	IN = open(bout, 'r')
	BLAT = IN.readlines()
	for j in range(5):
		BLAT.pop(0)
	for line in BLAT:
		d = line.split('\t')
		if int(d[4]) == 0:     # Qgap count filter
			qid  = d[9]
			qlen = int(d[10])
			tid  = d[13]
			tlen = int(d[14])
			strand = d[8]
			# The idea here is to load both FASTA files into one Dictionary, and then
			#   retrieve sequences based on a different key prefix: 'NULL'=Target; 'Q'=Query 
			#
			# Query sequence block . . . . . . . . . .
			qnumer = noder.search(qid)
			geneid = GeneID(qnumer.group(1))
			qnum   = "Q" + geneid
			
			if geneid not in GenList:      # Avoid multiple entries in contig table. 
				GenList.append(geneid) 
			
				# This is the target sequence block . . . . . .
				if count == 911:        # marker number for first pass
					tnumer = noder.search(tid)
					tnum   = GeneID(tnumer.group(1))
					commonid = GeneID(str(commoncount))
					commoncount += 1
					CommonID.append(commonid)
					cnum = tnum
					DataTable[commonid][targ]  = tnum
					DataTable[commonid][query] = geneid
				else:
					commoner = noder.search(tid)
					commonid = commoner.group(1)
					cnum = commonid
					DataTable[commonid][query] = geneid
				# -------------------------------------------
					
				head = 'NODE_%s' % commonid
				seq = ''
				if qlen > tlen:
					#if strand == '-':
					#	# reverse complement sequence . . . . .
					#	seq = RevComp(Seqs[qnum])
					#else:
						seq = Seqs[qnum] 
				else:
					seq = Seqs[cnum]
				CommonFasta.append(">%s\n%s\n" % (head,seq))
		
	# Write new common fasta file . . . .
	#     FASTA is freshly updated after each pass by doing a complete rewrite
	OUT = open("%s/CommonContigBuild-%s.fa" % (outdir,grp), 'w')
	for f in CommonFasta:
		OUT.write(f)
	OUT.close()
	CommonFasta[:] = []
	
	# Reset . . . . . . .
	tfile = "%s/CommonContigBuild-%s.fa" % (outdir,grp)
	count += 1
	# sys.exit()
	
#------------- DATA OUT ----------------------------------
Seqs.clear()
ReadFasta(tfile,'')                                              # <-- input the last updated version of 'CommonContigs'
FAout = open("%s/CommonContigBuild-%s.fa" % (outdir,grp), 'w')   # <-- prepare to write the FINAL version
OUT = open("%s/ContigTable-%s.txt" % (outdir,grp), 'w')
OUT.write("CID")
for s in xSamples:
	OUT.write("\t%s" % s)
OUT.write("\n")

for c in CommonID:
	found = 1
	for s in xSamples:
		try:
			if DataTable[c][s] == 'NF':
				found = 0
		except TypeError:
			found = 0
	if found == 1:
		OUT.write(c)
		for s in xSamples:
			OUT.write("\t%s" % DataTable[c][s])
		OUT.write("\n")
		FAout.write(">CNODE_%s\n%s\n" % (c,Seqs[c]))
OUT.close()
FAout.close()

print "\n\n       * * *      PROGRAM DONE      * * *\n"

#--- EOF -----------------------------------------------------------------------
#--- AGM-2011 ------------------------------------------------------------------
# ------------------------------------------------------------------------------

