#ifndef SIMPLE_DATA_LOGGER_H_
#define SIMPLE_DATA_LOGGER_H_

#include <cstdint>
#include <ctime>
#include <vector> 
#include <iostream>
#include <iomanip>
#include <sstream>
#include <fstream>
#include <string>

#include "file_ops.h"


//-----------------------------------------------------------------------------
class data_logger
{
public:

    data_logger() = default;
    
    data_logger(std::string directory, std::string base_name)
    {
        // make sure there is a path seperator 
        directory = path_check(directory);
        
        std::string current_date = get_date();
        
        // create the full log file name
        std::string filename = directory + base_name + "_" + current_date + ".txt";
        
        // open up file stream as txt file and appendable
        data_log.open(filename, std::ios::out | std::ios::app);
        
        // write a header with the log version and date
        data_log << "#-----------------------------------------------------------------------------" << std::endl;
        data_log << "# Version: " << log_version << std::endl;
        data_log << "# Date: " << current_date << std::endl;
        data_log << "#-----------------------------------------------------------------------------" << std::endl;
        data_log << std::endl;
    }
    
    ~data_logger()
    {
        data_log.close();
    }
    
    //-----------------------------------------------------------------------------
    void log_info(std::string msg)
    {
        data_log << error_code[0] << " ";
        data_log << get_time() << ": ";
        data_log << msg << std::endl;
    }   
    
    //-----------------------------------------------------------------------------
    void log_warning(std::string msg)
    {
        data_log << error_code[1] << " ";
        data_log << get_time() << ": ";
        data_log << msg << std::endl;
    }   
    
    //-----------------------------------------------------------------------------
    void log_error(std::string msg)
    {
        data_log << error_code[2] << " ";
        data_log << get_time() << ": ";
        data_log << msg << std::endl;
    }
       
    //-----------------------------------------------------------------------------
    void open(std::string filename)
    {}
    
    //-----------------------------------------------------------------------------
    void close()
    {
        data_log.close();
    }
    
//-----------------------------------------------------------------------------
private:
    std::ofstream data_log;
    std::vector<std::string> error_code = {"[INFO]", "[WARNING]", "[ERROR]"};
    std::string log_version = "1.0";
    
    //-----------------------------------------------------------------------------
    std::string get_time()
    {
        std::string format = "%H%M%S";
        char c_time[32];
        
        time_t now = time(NULL);
        struct tm *timeinfo = localtime(&now);;
        //timeinfo = 

        strftime(c_time, 7, format.c_str(), timeinfo);
        return std::string(c_time);
    }   // end of get_time
    
    //-----------------------------------------------------------------------------
    std::string get_date()
    {
        std::string format = "%Y%m%d";
        char c_date[32];
        
        time_t now = time(NULL);
        struct tm *timeinfo = localtime(&now); 
        //timeinfo ;

        strftime(c_date, 9, format.c_str(), timeinfo);

        return std::string(c_date);

    }   // end of get_date
};

#endif  // SIMPLE_DATA_LOGGER_H_
