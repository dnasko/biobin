using namespace std;

int NumSeqs(string file)
{
  string line;
  int seqs = 0;
  ifstream myfile (file);
  if (myfile.is_open())
    {
      while ( getline (myfile,line) )
	{
	  if ( line[0] == '>' ) {seqs++;}
	}
      myfile.close();
    }
  else cout << "Unable to open file"; 
  return seqs;
}

void Help(double version)
{
  cout << " ======= CASC Version " << version << " ======= " << endl;
  cout << endl;
  cout << endl;
  cout << " Usage: CASC [Options]" << endl;
  cout << endl;
  cout << "   -i   input filename in FASTA format. (Required)" << endl;
  cout << "   -o   output directory where all output files will be saved. Default will" << endl;
  cout << "        be the working directory. (Optional)" << endl;
  cout << "   -n   number of CPUs to use. Default = 1 (Optional)" << endl;
  cout << "   -c   be conservative with spacer calls. (Optional) By default CASC is" << endl;
  cout << "        liberal with calls." << endl;
  cout << "   -s   be silent and do not print updates to the screen. (Optional) By " << endl;
  cout << "        default CASC will print status updates to the screen" << endl;
  cout << "   -v   display the version (Optional)" << endl;
  cout << "   -h   display this help (Optional)" << endl;
  cout << endl;
  cout << endl;
}
