#ifndef _MMAP_H_
#define _MMAP_H_

#include <cstdint>
#include <string>
#include <vector>

#if defined(_WIN32) | defined(__WIN32__) | defined(__WIN32) | defined(_WIN64) | defined(__WIN64)
#include <windows.h>
//#pragma comment(lib, "user32.lib")
#else
#include <fcntl.h>
//#include <unistd.h>
//#include <sys/mman.h>
#include <sys/shm.h>
#include <sys/stat.h>
#endif

//#include <stdexcept>
//#include <streambuf>
//#include <cmath>

#if defined(_WIN32) | defined(__WIN32__) | defined(__WIN32) | defined(_WIN64) | defined(__WIN64)
#define MAP_FAILED NULL
#endif


// ----------------------------------------------------------------------------           
class mem_map
{
public:
            
    mem_map(std::string name_, uint64_t data_size) : name(name_)
    {
    //#if defined(_WIN32) | defined(__WIN32__) | defined(__WIN32) | defined(_WIN64) | defined(__WIN64)          
    //    map_handle_ = NULL;
    //#else
    //    file_handle_ = -1;
    //#endif

    //    map_address_ = MAP_FAILED;
                
    #if defined(_WIN32) | defined(__WIN32__) | defined(__WIN32) | defined(_WIN64) | defined(__WIN64)
        //file_handle_ = ::CreateFile(
        //    file_name.c_str(),
        //    GENERIC_READ | GENERIC_WRITE,
        //    FILE_SHARE_READ | FILE_SHARE_WRITE,
        //    NULL,
        //    OPEN_ALWAYS,
        //    FILE_ATTRIBUTE_NORMAL,
        //    NULL);

        //if (file_handle_ == INVALID_HANDLE_VALUE) 
        //{
        //    std::cout << "Error opening file: " << file_name << " " << GetLastError() << std::endl;
        //    return;
        //}

        //map_handle_ = ::CreateFileMapping(file_handle_, NULL, PAGE_READWRITE, 0, 0, NULL);
        map_handle_ = ::CreateFileMapping(INVALID_HANDLE_VALUE, NULL, PAGE_READWRITE, 0, data_size, name.c_str());

        if (map_handle_ == NULL) 
        {                    
            std::cout << "Error mapping file: " << GetLastError() << std::endl;
            close();
            return;
        }

        map_address_ = ::MapViewOfFile(map_handle_, FILE_MAP_ALL_ACCESS, 0, 0, data_size);
                
    #else
//        file_handle_ = open(name.c_str(), O_RDWR | O_CREAT | O_TRUNC);
//        if (file_handle_ == -1)
//        {
//            std::cout << "Error opening file." << std::endl;
//        }
//
//        struct stat sb;
//        if (fstat(file_handle_, &sb) == -1)
//        {
//            std::cout << "Error mapping file." << std::endl;
//            close();
//}
//        file_size_ = sb.st_size;

        map_handle_ = shm_open(name.c_str(), O_RDWR | O_CREAT, S_IRUSR | S_IWUSR);
        if (map_handle_ == -1)
        {
            std::cout << "Error opening shared memory..." << std::endl;
        }

        if (ftruncate(map_handle_, data_size) == -1)
        {
            std::cout << "Error configuring the size of the shared memory object..." << std::endl;
        }

        map_address_ = mmap(NULL, data_size, PROT_READ | PROT_WRITE, MAP_SHARED, map_handle_, 0);

    #endif

        if (map_address_ == MAP_FAILED) 
        {
            std::cout << "Error getting map address..." << std::endl;
            close();
        }                
                                         
    }   // end of open
            
// ----------------------------------------------------------------------------           
    void close()
    {
    #if defined(_WIN32) | defined(__WIN32__) | defined(__WIN32) | defined(_WIN64) | defined(__WIN64)
        if (map_address_) 
        {
            ::UnmapViewOfFile(map_address_);
            map_address_ = MAP_FAILED;
        }

        if (map_handle_) 
        {
            ::CloseHandle(map_handle_);
            map_handle_ = NULL;
        }

        //if (file_handle_ != INVALID_HANDLE_VALUE) 
        //{
        //    ::CloseHandle(file_handle_);
        //    file_handle_ = INVALID_HANDLE_VALUE;
        //}
            
    #else
        if (map_address_ != MAP_FAILED) 
        {
            munmap(map_address_, size_);
            map_address_ = NULL;
        }

        //if (file_handle_ != -1) 
        //{
        //    close(file_handle_);
        //    file_handle_ = -1;
        //}

        close(file_handle_);

        // remove the shared memory object
        shm_unlink(name.c_str());

    #endif

    }   // end of close
        
// ----------------------------------------------------------------------------
    template <typename T>
    inline void read(uint64_t &position, T &data)
    {
        uint8_t* bytes = reinterpret_cast<uint8_t*>(&data);

        for (uint8_t idx = 0; idx < sizeof(T); ++idx)
        {
            read_data(position, bytes[idx]);
        }
    }

// ----------------------------------------------------------------------------
    template <typename T>
    inline void read_range(uint64_t &position, uint64_t length, std::vector<T> &data)
    {
        data.clear();
            
        for(uint64_t idx=0; idx<length; ++idx)
        {
            T d;
            read(position, d);
            data.push_back(d);       
        }         
    }   // end of read_range

// ----------------------------------------------------------------------------------------
    template <typename T>
    inline void write(uint64_t &position, T data)
    {
        uint8_t* bytes = reinterpret_cast<uint8_t*>(&data);

        for (uint8_t idx = 0; idx < sizeof(T); ++idx)
        {
            write_data(position, bytes[idx]);
        }
    }   // end of write

// ----------------------------------------------------------------------------------------
    template <typename T>
    inline void write_range(uint64_t &position, std::vector<T> data)
    {
        //if (position+data.size() >= file_size_)
        //    return;

        for (uint64_t idx = 0; idx < data.size(); ++idx)
        {
            write(position, data[idx]);
        }
    }

// ----------------------------------------------------------------------------------------
private:
        
#if defined(_WIN32) | defined(__WIN32__) | defined(__WIN32) | defined(_WIN64) | defined(__WIN64)
    HANDLE map_handle_;
#else
    int32_t map_handle_;
#endif
        
    void* map_address_;

    std::string name;

// ----------------------------------------------------------------------------           
    inline void read_data(uint64_t& position, uint8_t& data)
    {
        data = *((uint8_t*)(map_address_)+position);
        ++position;
    }   // end of read_data
            
    inline void write_data(uint64_t& position, uint8_t data)
    {
        uint8_t* d = ((uint8_t*)(map_address_)+position);
        *d = data;
        ++position;
    }   // end of write_data


};   // end of class

#endif  // _MMAP_H_
