#ifndef _IQ_UTILS_H_
#define _IQ_UTILS_H_

#include <cstdint>
#include <string>
#include <complex>
#include <sstream>
#include <fstream>

//#include <file_parser.h>

//-----------------------------------------------------------------------------
template <typename T>
void write_iq_data(std::string filename, std::vector<T>& samples)
{
    std::ofstream data_file;

    try
    {
        data_file.open(filename, std::ios::out | std::ios::binary);

        if (!data_file.is_open())
        {
            std::cout << "Could not open file to save data... " << std::endl;
            return;
        }

        data_file.write(reinterpret_cast<const char*>(samples.data()), samples.size() * sizeof(T));

        data_file.close();
    }
    catch (std::exception e)
    {
        std::cout << "Could not open file to write data: " << e.what() << std::endl;
    }
}

//-----------------------------------------------------------------------------
template <typename T>
void write_iq_data(std::string filename, std::vector<std::complex<T>> &samples)
{
    std::ofstream data_file;

    try
    {
        data_file.open(filename, std::ios::out | std::ios::binary);

        if (!data_file.is_open())
        {
            std::cout << "Could not open file to save data... " << std::endl;
            return;
        }

        data_file.write(reinterpret_cast<const char*>(samples.data()), 2 * samples.size() * sizeof(T));

        data_file.close();
    }
    catch(std::exception e)
    {
        std::cout << "Could not open file to write data: " << e.what() << std::endl;
    }
}

//-----------------------------------------------------------------------------
template <typename T>
void read_iq_data(std::string filename, std::vector<std::complex<T>> &samples)
{

    samples.clear();
    std::ifstream data_file;

    try
    {
        data_file.open(filename, std::ios::binary | std::ios::ate);

        if (!data_file.is_open())
        {
            std::cout << "Could not open file to read data" << std::endl;
            return;
        }
        
        // get the number of bytes in the file
        auto file_size = data_file.tellg();
        data_file.seekg(0, std::ios::beg);

        // set the size of the samples container based on the file size and the size 
        samples.resize(std::floor(file_size/sizeof(T)));
        
        data_file.read(reinterpret_cast<char*>(samples.data()), file_size);

        data_file.close();
    }
    catch(std::exception e)
    {
        std::cout << "Could not open file to read data: " << e.what() << std::endl;
    }

}


#endif  // end of _IQ_UTILS_H_

