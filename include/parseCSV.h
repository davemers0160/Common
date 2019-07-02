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


#endif	// PARSE_CSV_H_