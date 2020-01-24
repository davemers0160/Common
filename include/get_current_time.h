#define _CRT_SECURE_NO_WARNINGS

#ifndef GET_CURRENT_TIME_H_
#define GET_CURRENT_TIME_H_

// #include <vector> 
// #include <iostream>
// #include <sstream>
// #include <fstream>
#include <ctime>



//std::string get_date(const struct tm &timeinfo)
//{
//
//}

// ----------------------------------------------------------------------------------------
std::string get_date(const std::string &format)
{
    time_t rawtime;
    struct tm *timeinfo; 
    
    char c_date[32];

    time(&rawtime);
    timeinfo = localtime(&rawtime);

    strftime(c_date, 9, format.c_str(), timeinfo);

    return (std::string)(c_date);

}   // end of get_date

// ----------------------------------------------------------------------------------------
std::string get_time(const std::string &format)
{
    time_t rawtime;
    struct tm *timeinfo;

    char c_time[32];

    time(&rawtime);
    timeinfo = localtime(&rawtime);

    strftime(c_time, 7, format.c_str(), timeinfo);

    return (std::string)(c_time);

}   // end of get_time

// ----------------------------------------------------------------------------------------
void get_current_time(std::string &sdate, std::string &stime)
{
	//time_t rawtime;
	//struct tm * timeinfo;

	//char c_date[9];
	//char c_time[7];
	//
	//time(&rawtime);
	//timeinfo = localtime(&rawtime);

	//strftime(c_date, 9, "%Y%m%d", timeinfo);
	//strftime(c_time, 7, "%H%M%S", timeinfo);
	//
	//sdate = (std::string)(c_date);
	//stime = (std::string)(c_time);

    sdate = get_date("%Y%m%d");
    stime = get_time("%H%M%S");
	
}	// end of get_current_time

#endif  // GET_CURRENT_TIME_H_