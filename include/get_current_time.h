#ifndef GET_CURRENT_TIME_H_
#define GET_CURRENT_TIME_H_

// #include <vector> 
// #include <iostream>
// #include <sstream>
// #include <fstream>
#include <ctime>

using namespace std;

void get_current_time(std::string &sdate, std::string &stime)
{
	time_t rawtime;
	struct tm * timeinfo;

	char c_date[9];
	char c_time[7];
	
	time(&rawtime);
	timeinfo = localtime(&rawtime);

	strftime(c_date, 9, "%Y%m%d", timeinfo);
	strftime(c_time, 7, "%H%M%S", timeinfo);
	
	sdate = (std::string)(c_date);
	stime = (std::string)(c_time);
	
}	// end of getCurrentTime


#endif  // GET_CURRENT_TIME_H_