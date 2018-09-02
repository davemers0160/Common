#ifndef PARSE_CSV_H_
#define PARSE_CSV_H_

#include <algorithm>
#include <vector> 
#include <iostream>
#include <sstream>
#include <fstream>
//#include <cctype>
//#include <locale>

using namespace std;

// trim from start (in place)
static inline void ltrim(std::string &s) {
	s.erase(s.begin(), std::find_if(s.begin(), s.end(), [](int ch) {
		return !std::isspace(ch);
	}));
}

// trim from end (in place)
static inline void rtrim(std::string &s) {
	s.erase(std::find_if(s.rbegin(), s.rend(), [](int ch) {
		return !std::isspace(ch);
	}).base(), s.end());
}

// trim from both ends (in place)
static inline void trim(std::string &s) {
	ltrim(s);
	rtrim(s);
}


void parseCSVLine(std::string line, std::vector<std::string> &line_params)
{
    stringstream ss(line);
    while (ss.good())
    {

        std::string substr;
        getline(ss, substr, ',');
        trim(substr);
        if (substr.size() > 0)
        {
            line_params.push_back(substr);
        }

    }   
    
}   // end of parseCSVLine


void parseCSVFile(std::string parseFilename, std::vector<std::vector<std::string>> &params)
{
	std::ifstream csvfile(parseFilename);
	std::string nextLine;

	while (std::getline(csvfile, nextLine))
	{
		if ((nextLine[0] != '#') && (nextLine.size() > 0))
		{
			std::vector<std::string> line_params;
            
            parseCSVLine(nextLine, line_params);
            
			// stringstream ss(nextLine);
			// while (ss.good())
			// {

				// std::string substr;
				// getline(ss, substr, ',');
				// trim(substr);
				// if (substr.size() > 0)
				// {
					// line_params.push_back(substr);
				// }

			// }

			if (line_params.size() > 0)
			{
				params.push_back(line_params);
			}

		}
	}


}	// end of parseCSVFile

void parseDNNDataFile(std::string parseFilename, std::vector<std::vector<std::string>> &params)
{
    /*
    # The input file to this code should have the following organizational format:
    # training_file: This file contains a list of images and labels used for training
    # test_file: This file contains a list of images and labels used for testing
    # crop_num: The number of crops to use when using a random cropper
    # crop_size: This is the height and width of the crop size.  Should be a comma separated list, eg. 20,20
    # filter_num: This is the number of filters per layer.  Should be a comma separated list, eg. 10,20,30
    #             if the list does not account for the entire network then the code only uses what is available
    #             and leaves the remaining filter number whatever the default value was.  The order of the filters
    #             goes from outer most to the inner most layer.
    */
    
	std::ifstream csvfile(parseFilename);
	std::string nextLine;
    int line_count = 0; // use to keep track of which line we are currently parsing
    
	while (std::getline(csvfile, nextLine))
	{
		if ((nextLine[0] != '#') && (nextLine.size() > 0))
		{
            switch(line_count)
            {
                case 0:
                
                    break;
                    
                case 1:
                
                
                    break;
                    
                case 2:
                    
                    break;
                    
                case 3:
                
                    break;
                
                case 4:
                    
                    
                    break;
                    
                default:
                    break;
            }
    
    
            ++line_count;
        }
    }        
    

}   // end of parseDNNDataFile




#endif	// PARSE_CSV_H_