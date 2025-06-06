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
#include <chrono>

#include "file_ops.h"

//-----------------------------------------------------------------------------
inline std::string get_time()
{
    std::string format = "%H%M%S";
    char c_time[32];

    time_t now_t = time(NULL);
    struct tm* timeinfo = localtime(&now_t);

    strftime(c_time, 11, format.c_str(), timeinfo);

    auto now = std::chrono::system_clock::now();
    auto now_seconds = std::chrono::time_point_cast<std::chrono::seconds>(now);
    //auto fraction = now - now_seconds;
    //auto milliseconds = std::chrono::duration_cast<std::chrono::milliseconds>(fraction);

    // Calculate fractional seconds
    auto duration = now.time_since_epoch();
    auto milliseconds = std::chrono::duration_cast<std::chrono::milliseconds>(duration);

    std::stringstream ss;
    ss << std::setfill('0') << std::setw(3) << milliseconds.count() % 1000;

    return std::string(c_time) + "." + ss.str();

}   // end of get_time

//-----------------------------------------------------------------------------
inline std::string get_date()
{
    std::string format = "%Y%m%d";
    char c_date[32];

    time_t now = time(NULL);
    struct tm* timeinfo = localtime(&now);
    //timeinfo ;

    strftime(c_date, 9, format.c_str(), timeinfo);

    return std::string(c_date);

}   // end of get_date

//-----------------------------------------------------------------------------
std::ostream& info(std::ostream& os) 
{
    os << "[INFO]  " << get_time() << ": ";
    return os;
}

//-----------------------------------------------------------------------------
std::ostream& warning(std::ostream& os)
{
    os << "[WARN]  " << get_time() << ": ";
    return os;
}

//-----------------------------------------------------------------------------
class error
{
public:
    error(const char* fn, int32_t ln) : filename(fn), line_num(ln) {}

    friend std::ostream& operator<<(std::ostream& os, const error& er)
    {
        os << "[ERROR] " << get_time() << ": ";
        os << get_file_name(er.filename) << " (Line: " << std::to_string(er.line_num) << "): ";
        return os;
    }

private:
    std::string filename;
    int32_t line_num;
};

//-----------------------------------------------------------------------------
//class data_logger
//{
//public:
//
//    data_logger() = default;
//    
//    data_logger(std::string directory, std::string base_name)
//    {
//        // make sure there is a path seperator 
//        directory = path_check(directory);
//        
//        std::string current_date = get_date();
//        
//        // create the full log file name
//        std::string filename = directory + base_name + "_" + current_date + ".txt";
//        
//        // open up file stream as txt file and appendable
//        data_log.open(filename, std::ios::out | std::ios::app);
//        
//        // write a header with the log version and date
//        data_log << "#-----------------------------------------------------------------------------" << std::endl;
//        data_log << "# Version: " << log_version << std::endl;
//        data_log << "# Date: " << current_date << std::endl;
//        data_log << "#-----------------------------------------------------------------------------" << std::endl;
//        data_log << std::endl;
//    }
//    
//    ~data_logger()
//    {
//        data_log.close();
//    }
//    
//    //-----------------------------------------------------------------------------
//    void log_info(std::string msg)
//    {
//        data_log << error_code[0] << "  ";
//        data_log << get_time() << ": ";
//        data_log << msg << std::endl;
//    }   
//    
//    //-----------------------------------------------------------------------------
//    void log_warning(std::string msg)
//    {
//        data_log << error_code[1] << "  ";
//        data_log << get_time() << ": ";
//        data_log << msg << std::endl;
//    }   
//    
//    //-----------------------------------------------------------------------------
//    void log_error(std::string filename, int32_t line_num, std::string msg)
//    {
//        data_log << error_code[2] << " ";
//        data_log << get_time() << ": ";
//        data_log << get_file_name(filename) << " (" << std::to_string(line_num) << "): ";
//        data_log << msg << std::endl;
//    }
//       
//    //-----------------------------------------------------------------------------
//    void open(std::string filename)
//    {}
//    
//    //-----------------------------------------------------------------------------
//    void close()
//    {
//        data_log.close();
//    }
//
//    //-----------------------------------------------------------------------------
//    template <typename T>
//    std::ostream& operator<<(T v)
//    {
//        data_log << v;
//        return data_log;
//    }
//    
//    std::string info() 
//    {
//        return error_code[0] + "  " + get_time() + ": ";
//    }
//
//    std::string warn()
//    {
//        return error_code[1] + "  " + get_time() + ": ";
//    }
//
////-----------------------------------------------------------------------------
//private:
//    std::ofstream data_log;
//    std::vector<std::string> error_code = {"[INFO]", "[WARN]", "[ERROR]", "[TEST]"};
//    std::string log_version = "1.0";
//    
//    //-----------------------------------------------------------------------------
//    std::string get_time()
//    {
//        std::string format = "%H%M%S";
//        char c_time[32];
//        
//        time_t now = time(NULL);
//        struct tm *timeinfo = localtime(&now);;
//        //timeinfo = 
//
//        strftime(c_time, 7, format.c_str(), timeinfo);
//        return std::string(c_time);
//    }   // end of get_time
//    
//    //-----------------------------------------------------------------------------
//    std::string get_date()
//    {
//        std::string format = "%Y%m%d";
//        char c_date[32];
//        
//        time_t now = time(NULL);
//        struct tm *timeinfo = localtime(&now); 
//        //timeinfo ;
//
//        strftime(c_date, 9, format.c_str(), timeinfo);
//
//        return std::string(c_date);
//
//    }   // end of get_date
//};

#endif  // SIMPLE_DATA_LOGGER_H_
