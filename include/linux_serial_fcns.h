#ifndef _LINUX_SERIAL_CTRL_H_
#define _LINUX_SERIAL_CTRL_H_


#include <cstdint>

#include <fcntl.h> 			// Contains file controls like O_RDWR
#include <errno.h> 			// Error integer and strerror() function
#include <termios.h> 		// Contains POSIX terminal control definitions
#include <unistd.h> 		// write(), read(), close()

#include <string>
#include <vector>
#include <stdexcept>


//-----------------------------------------------------------------------------
class serial_port
{

private:
	int port;
	struct termios settings;

//-----------------------------------------------------------------------------
	void config(uint32_t baud_rate, uint32_t wait_time)
	{
		// get the current port configuration
		tcgetattr(port, &settings);

		// set the baud rate
		cfsetispeed(&settings, baud_rate);
		cfsetospeed(&settings, baud_rate);

		settings.c_cflag &= ~PARENB;		// No Parity
		settings.c_cflag &= ~CSTOPB;		// Stop bits = 1 
		settings.c_cflag &= ~CSIZE;			// Clears the Mask
		settings.c_cflag |=  CS8;			// Set the data bits = 8

		// Turn off hardware based flow control (RTS/CTS).
		settings.c_cflag &= ~CRTSCTS;

		// Turn on the receiver of the serial port (CREAD), other wise reading from the serial port will not work.
		settings.c_cflag |= CREAD | CLOCAL;

		// Turn off software based flow control (XON/XOFF).
		settings.c_iflag &= ~(IXON | IXOFF | IXANY);

		// Setting the mode of operation,the default mode of operation of serial port in 
		// Linux is the Cannonical mode. For Serial communications with outside devices 
		// like serial modems, mice etc NON Cannonical mode is recommended.
		settings.c_iflag &= ~(ICANON | ECHO | ECHOE | ISIG);
		
		// Prevent special interpretation of output bytes (e.g. newline chars)
		settings.c_oflag &= ~(OPOST | ONLCR); 

		// set wait time
		settings.c_cc[VTIME] = wait_time;    // Wait for up to 1s (100ms increments), returning as soon as any data is received.
		settings.c_cc[VMIN] = 0;
		
		// Save tty settings, also checking for error
		int res = tcsetattr(port, TCSANOW, &settings);
		if (res != 0) 
			throw std::runtime_error("Error from tcsetattr: " + strerror(errno));
		
	}

//-----------------------------------------------------------------------------
public:

	serial_port() = default;
	
//-----------------------------------------------------------------------------
	void open(std::string named_port, uint32_t baud_rate, uint32_t wait_time)
	{
		port = open(named_port.c_str(), O_RDWR | O_NOCTTY);
		
		if(port == 1)
		{
			throw std::runtime_error("Error opening port: " + named_port);
			return;
		}
		
		config(baud_rate, wait_time);
		
	}

//-----------------------------------------------------------------------------
	void read(std::vector<uint8_t> &read_bufffer, uint64_t count)
	{
		read_bufffer.clear();
		read_bufffer.resize(count);
		
		int num_bytes = read(port, &read_bufffer[0], count);
		
		if(num_bytes != count)
		{
			throw std::runtime_error("Wrong number of bytes received. Expected: " + count.to_string() + ", received: " + num_bytes.to_string());
			return;			
		}
			
	}
	
	void read(std::string &read_bufffer, uint64_t count)
	{
		std::vector<uint8_t> rb(count);
		
		read(rb,  count);
					
		read_bufffer.assign(rb.begin(), rb.end());
				
	}

//-----------------------------------------------------------------------------
	void write(std::vector<uint8_t> write_buffer)
	{
		int bytes_written = write(port, write_buffer, write_buffer.size());		
	}
	
	void write(std::string write_buffer)
	{
		int bytes_written = write(port, write_buffer.c_str(), write_buffer.length());
	}
	
//-----------------------------------------------------------------------------
	void close()
	{
		close(port);
		port = NULL;
	}

};	// end of class

#endif	// _LINUX_SERIAL_CTRL_H_
