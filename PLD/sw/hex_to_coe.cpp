#include <iostream>

#include <iostream>
#include <fstream>
#include <assert.h>
#include <cstdlib>
#include <string>


using namespace std;
int main()
{
     ifstream fin;     // declare stream variable name
     ofstream fout;
     string line;
     char output[3];	// 2 chars + termination
     /* These could be inputs */

	 long max_address = 0xFFFF;
	 unsigned char default_value = 0;

     unsigned char buffer[65536];
     unsigned char byte_count;

     char * p;

     long i;
     int j;
     long address;
     long address_offset = 0;

     for (i=0; i <= max_address; i++)
	 {
	 	buffer[i] = default_value;
	 }

     fin.open("filename.hex",ios::in);    // open file
     assert (!fin.fail( ));
	 getline(fin, line);
     while (!fin.eof( ))      //if not at end of file, continue reading numbers
     {
		cout << line << endl;
		switch (line[8])
		{
			case '0':
			{
				/* This is data */
				/* First two bytes = number of bytes in hex */
				byte_count = strtol(line.substr(1,2).c_str(), &p, 16);
				/* check address */
				address = address_offset + strtol(line.substr(3,4).c_str(), &p, 16);
				if (address <= max_address)
				{
					for (i = 0; i < byte_count; i++)
					{
						buffer[address + i] = strtol(line.substr(9+i*2,2).c_str(), &p, 16);
					}
				}
				else
				{
					cout << "Invalid Address" << endl;
					assert(1);
				}
				break;
			}
			case '1':
			{
				cout << "File complete." << endl;
				break;
			}
			case '4':
			{
				address_offset = strtol(line.substr(9,4).c_str(), &p, 16);
				cout << "New high address = " << line.substr(9,4) << endl;
				break;
			}
			default:
			{
				cout << "Invalid line in hex file." << endl;
				assert(1);
				break;
			}
		}
		getline(fin, line);
     }
     fin.close( );       //close file
     /* Now genereate coe file from buffer */
     fout.open("filename.coe",ios::out);
     fout << "; COE File Generated from filename.hex" << endl;
     fout << "memory_initialization_radix=16;" << endl;
     fout << "memory_initialization_vector=" << endl;
	 i = 0;
	 while (i <= max_address)
	 {
	 	for (j= 0; j < 32; j++)
		{
			sprintf((char*) &output, "%02X", buffer[i+j]);
			fout << output << " ";
		}
		fout << endl;
	 	i = i + 32;
	 }

     fout.close();
}
