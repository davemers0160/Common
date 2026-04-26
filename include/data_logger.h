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
    std::chrono::system_clock::time_point now = std::chrono::system_clock::now();

    // Convert the time point to a time_t object
    std::time_t now_c = std::chrono::system_clock::to_time_t(now);

    // Convert the time_t object to a local time
    std::tm now_tm  = *localtime(&now_c);

    // get the millisecond time
    auto ms = std::chrono::duration_cast<std::chrono::milliseconds>(now.time_since_epoch()) % 1000;

    std::stringstream ss;
    ss << std::put_time(&now_tm, "%H%M%S") << "." << std::setfill('0') << std::setw(3) << ms.count() % 1000;
    
    return  ss.str();

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
    os << "[INFO -  " << get_time() << "]: ";
    return os;
}

//-----------------------------------------------------------------------------
std::ostream& warning(std::ostream& os)
{
    os << "[WARN -  " << get_time() << "]: ";
    return os;
}

//-----------------------------------------------------------------------------
class error
{
public:
    error(const char* fn, int32_t ln) : filename(fn), line_num(ln) {}

    friend std::ostream& operator<<(std::ostream& os, const error& er)
    {
        os << "[ERROR - " << get_time() << "]: ";
        os << get_file_name(er.filename) << " (Line: " << std::to_string(er.line_num) << "): ";
        return os;
    }

private:
    std::string filename;
    int32_t line_num;
};  // end of error class

//-----------------------------------------------------------------------------
// custom streambuf that redirects output to two destinations
class dual_stream_buffer : public std::streambuf 
{
public:
    dual_stream_buffer(std::streambuf* first, std::streambuf* second)
        : buffer_first(first), buffer_second(second) {}

protected:
    //-----------------------------------------------------------------------------
    // override overflow to write to both buffers
    virtual int overflow(int c) override 
    {
        if (c == EOF) 
            return !EOF;

        bool fail = false;
        if (buffer_first->sputc(c) == EOF) 
            fail = true;
        
        if (buffer_second->sputc(c) == EOF) 
            fail = true;

        return fail ? EOF : c;
    }   // end of overflow

    //-----------------------------------------------------------------------------
    // override sync to ensure both destinations are flushed
    virtual int sync() override 
    {
        int res_first = buffer_first->pubsync();
        int res_second = buffer_second->pubsync();
        
        return (res_first == 0 && res_second == 0) ? 0 : -1;
    }   // end of sync

private:
    std::streambuf* buffer_first;
    std::streambuf* buffer_second;
    
};  // end of dual_stream_buffer class

//-----------------------------------------------------------------------------
// manager class to handle the redirection life-cycle (RAII)
class stream_redirector 
{
public:
    //-----------------------------------------------------------------------------
    stream_redirector(const std::string& file_name) 
    {
        output_file.open(file_name, std::ios::out | std::ios::app);
        
        if (output_file.is_open()) 
        {
            // create dual buffers for cout and cerr
            cout_dual_buffer = std::make_unique<dual_stream_buffer>(std::cout.rdbuf(), output_file.rdbuf());
            
            cerr_dual_buffer = std::make_unique<dual_stream_buffer>(std::cerr.rdbuf(), output_file.rdbuf());

            // redirect global streams
            old_cout_buffer = std::cout.rdbuf(cout_dual_buffer.get());
            old_cerr_buffer = std::cerr.rdbuf(cerr_dual_buffer.get());
        }
    }

    //-----------------------------------------------------------------------------
    // restore original buffers on destruction
    ~stream_redirector() 
    {
        if (old_cout_buffer) 
            std::cout.rdbuf(old_cout_buffer);
        
        if (old_cerr_buffer) 
            std::cerr.rdbuf(old_cerr_buffer);
    }

private:
    std::ofstream output_file;
    std::streambuf* old_cout_buffer = nullptr;
    std::streambuf* old_cerr_buffer = nullptr;
    std::unique_ptr<dual_stream_buffer> cout_dual_buffer;
    std::unique_ptr<dual_stream_buffer> cerr_dual_buffer;
    
};  // end of stream_redirector class


#endif  // SIMPLE_DATA_LOGGER_H_
