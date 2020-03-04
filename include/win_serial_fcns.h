#ifndef _WINDOWS_SERIAL_CTRL_H_
#define _WINDOWS_SERIAL_CTRL_H_

#include <windows.h>

#include <cstdint>
#include <string>
#include <vector>
#include <stdexcept>

// https://www.codeguru.com/cpp/i-n/network/serialcommunications/article.php/c5425/Serial-Communication-in-Windows.htm

//-----------------------------------------------------------------------------
class serial_port
{

private:
    HANDLE port;
    DCB settings = {0};
    
//-----------------------------------------------------------------------------
    void config(uint32_t baud_rate, uint32_t wait_time)
    {
        settings.DCBlength = sizeof(settings);

        //After that retrieve the current settings of the serial port using the GetCommState() function.
        bool Status = GetCommState(port, &settings);

        // set the values for Baud rate, Byte size, Number of start/Stop bits etc.
        settings.BaudRate = baud_rate;                              // Setting BaudRate
        settings.ByteSize = 8;                                      // Setting ByteSize = 8
        settings.StopBits = ONESTOPBIT;                             // Setting StopBits = 1
        settings.Parity = NOPARITY;                                 // Setting Parity = None
        
        COMMTIMEOUTS timeouts = { 0 };
        timeouts.ReadIntervalTimeout = wait_time*100;               // in milliseconds
        timeouts.ReadTotalTimeoutConstant = wait_time*100;          // in milliseconds
        timeouts.ReadTotalTimeoutMultiplier = wait_time*100;        // in milliseconds
        timeouts.WriteTotalTimeoutConstant = wait_time*100;         // in milliseconds
        timeouts.WriteTotalTimeoutMultiplier = wait_time*100;       // in milliseconds
        SetCommTimeouts (port, &timeouts);
        
        SetCommState(port, &settings);
    }   // end of config

//-----------------------------------------------------------------------------
public:

    serial_port() = default;
    
//-----------------------------------------------------------------------------
    void open_port(std::string named_port, uint32_t baud_rate, uint32_t wait_time)
    {
        //  Open a handle to the specified com port: expect COMX
        named_port = "\\\\.\\" + named_port;
        port = CreateFile(named_port.c_str(),
              GENERIC_READ | GENERIC_WRITE,
              0,                            //  must be opened with exclusive-access
              NULL,                         //  default security attributes
              OPEN_EXISTING,                //  must use OPEN_EXISTING
              0,                            //  not overlapped I/O
              NULL );                       //  hTemplate must be NULL for comm devices
              
        if(port == INVALID_HANDLE_VALUE)
        {
            throw std::runtime_error("Error opening port: " + named_port);
            return;
        }

        config(baud_rate, wait_time);

    }   // end of open_port


//-----------------------------------------------------------------------------
    uint64_t read_port(std::vector<uint8_t> &read_bufffer, uint64_t count)
    {
        unsigned long num_bytes = 0;                        // Number of bytes read from the port
        unsigned long event_mask = 0;

        read_bufffer.clear();
        read_bufffer.resize(count);
        
        // set the events to be monitored for a communication device: EV_TXTEMPTY|EV_RXCHAR
        //bool Status = SetCommMask(port, EV_RXCHAR);
        
        // wait for the events set by SetCommMask() to happen
        //Status = WaitCommEvent(port, &event_mask, NULL); 
        
        ReadFile(port,                              // Handle of the Serial port
                &read_bufffer[0],                   // Buffer to store the data
                count,                              // Number of bytes to read in
                &num_bytes,                         // Number of bytes actually read
                NULL);
             
        // if(num_bytes != count)
        // {
            // throw std::runtime_error("Wrong number of bytes received. Expected: " + count.to_string() + ", received: " + num_bytes.to_string());
            // return;
        // }      

		return num_bytes;		
    }   // end of read_port

    uint64_t read_port(std::string &read_bufffer, uint64_t count)
    {
        std::vector<uint8_t> rb(count);
        
        uint64_t num_bytes = read_port(rb,  count);

        read_bufffer.assign(rb.begin(), rb.end());
		return num_bytes;		
    }   // end of read_port
  
//-----------------------------------------------------------------------------
    uint64_t write_port(std::vector<char> write_buffer)
    {
        unsigned long bytes_written = 0;                  // Number of bytes written to the port


        bool Status = WriteFile(port,               // Handle to the Serial port
            write_buffer.data(),        // Data to be written to the port
            write_buffer.size(),        // No of bytes to write
            &bytes_written,             // Bytes written
            NULL);

        return bytes_written;
    }   // end of write_port

    uint64_t write_port(std::vector<uint8_t> write_buffer)
    {
        unsigned long bytes_written = 0;                  // Number of bytes written to the port
        
        bool Status = WriteFile(port,               // Handle to the Serial port
                        write_buffer.data(),        // Data to be written to the port
                        write_buffer.size(),        // No of bytes to write
                        &bytes_written,             // Bytes written
                        NULL);

        return bytes_written;
    }   // end of write_port
    
    uint64_t write_port(std::string write_buffer)
    {
        unsigned long bytes_written = 0;                  // Number of bytes written to the port
        
        bool Status = WriteFile(port,               // Handle to the Serial port
                        write_buffer.c_str(),       // Data to be written to the port
                        write_buffer.length(),      // No of bytes to write
                        &bytes_written,             // Bytes written
                        NULL); 
                        
        return bytes_written;
    }   // end of write_port

//-----------------------------------------------------------------------------
    void flush_port()
    {
        sleep_ms(1);
        PurgeComm(port, PURGE_RXABORT | PURGE_RXCLEAR | PURGE_TXABORT | PURGE_TXCLEAR);
    }   // end of flush_port

    inline int64_t bytes_available()
    {
        int64_t bytes_avail = -1;
        COMSTAT cs;
        unsigned long error;

        if (ClearCommError(port, &error, &cs))
            bytes_avail = (int64_t)cs.cbInQue;

        return bytes_avail;
    }   // end of bytes_available

//-----------------------------------------------------------------------------
    void close_port()
    {
        CloseHandle(port);
        //port = NULL;
    }   // end of close_port

};    // end of class
    
#endif  // _WINDOWS_SERIAL_CTRL_H_
