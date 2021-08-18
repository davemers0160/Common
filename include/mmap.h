#ifndef _MMAP_H_
#define _MMAP_H_

#include <cstdint>
#include <string>
#include <vector>

#if defined(_WIN32) | defined(__WIN32__) | defined(__WIN32) | defined(_WIN64) | defined(__WIN64)
#include <windows.h>

#else

#include <unistd.h>
#include <sys/mman.h>
#include <sys/shm.h>
#include <sys/stat.h>
#include <fcntl.h>
#endif


#if defined(_WIN32) | defined(__WIN32__) | defined(__WIN32) | defined(_WIN64) | defined(__WIN64)
const int MAP_FAILED = NULL;
#endif


// ----------------------------------------------------------------------------           
class mem_map
{
public:
            
    mem_map(std::string name_, uint64_t ds_) : name(name_), data_size(ds_)
    {

                
    #if defined(_WIN32) | defined(__WIN32__) | defined(__WIN32) | defined(_WIN64) | defined(__WIN64)

        map_handle = ::CreateFileMapping(INVALID_HANDLE_VALUE, NULL, PAGE_READWRITE, 0, data_size, name.c_str());

        if (map_handle == NULL) 
        {                    
            std::cout << "Error mapping file: " << GetLastError() << std::endl;
            close();
            return;
        }

        map_address = ::MapViewOfFile(map_handle, FILE_MAP_ALL_ACCESS, 0, 0, data_size);
                
    #else

        map_handle = shm_open(name.c_str(), O_RDWR | O_CREAT, S_IRUSR | S_IWUSR);
        if (map_handle == -1)
        {
            std::cout << "Error opening shared memory..." << std::endl;
        }

        if (ftruncate(map_handle, data_size) == -1)
        {
            std::cout << "Error configuring the size of the shared memory object..." << std::endl;
        }

        map_address = mmap(NULL, data_size, PROT_READ | PROT_WRITE, MAP_SHARED, map_handle, 0);

    #endif

        if (map_address == MAP_FAILED) 
        {
            std::cout << "Error getting map address..." << std::endl;
            close();
        }                
                                         
    }   // end of open
            
// ----------------------------------------------------------------------------           
    void close()
    {
    #if defined(_WIN32) | defined(__WIN32__) | defined(__WIN32) | defined(_WIN64) | defined(__WIN64)
        if (map_address != MAP_FAILED) 
        {
            ::UnmapViewOfFile(map_address);
            map_address = MAP_FAILED;
        }

        if (map_handle) 
        {
            ::CloseHandle(map_handle);
            map_handle = NULL;
        }
            
    #else
        if (map_address != MAP_FAILED) 
        {
            munmap(map_address, data_size);
            map_address = NULL;
        }

        //close();

        // remove the shared memory object
        shm_unlink(name.c_str());

    #endif

    }   // end of close
        
// ----------------------------------------------------------------------------
    template <typename T>
    inline T* get_address(uint64_t position)
    {
        return (reinterpret_cast<T*>(map_address) + position);
    }

// ----------------------------------------------------------------------------
    template <typename T>
    inline void read(uint64_t position, T &data)
    {
        uint8_t* bytes = reinterpret_cast<uint8_t*>(&data);

        for (uint8_t idx = 0; idx < sizeof(T); ++idx)
        {
            read_data(position + idx, bytes[idx]);
        }
    }

// ----------------------------------------------------------------------------
    template <typename T>
    inline void read_range(uint64_t position, uint64_t length, std::vector<T> &data)
    {
        data.clear();
            
        for(uint64_t idx=0; idx<length; ++idx)
        {
            T d;
            read(position + idx, d);
            data.push_back(d);       
        }         
    }   // end of read_range

// ----------------------------------------------------------------------------------------
    template <typename T>
    inline void write(uint64_t position, T data)
    {
        uint8_t* bytes = reinterpret_cast<uint8_t*>(&data);

        for (uint8_t idx = 0; idx < sizeof(T); ++idx)
        {
            write_data(position + idx, bytes[idx]);
        }
    }   // end of write

// ----------------------------------------------------------------------------------------
    template <typename T>
    inline void write_range(uint64_t position, std::vector<T> data)
    {
        //if (position+data.size() >= file_size_)
        //    return;

        for (uint64_t idx = 0; idx < data.size(); ++idx)
        {
            write(position + idx, data[idx]);
        }
    }   // end of write_range

    template <typename T>
    inline void write_range(uint64_t position, uint64_t length, T *data)
    {
        //if (position+data.size() >= file_size_)
        //    return;

        for (uint64_t idx = 0; idx < length; ++idx)
        {
            write(position + idx, data[idx]);
        }
    }   // end of write_range


// ----------------------------------------------------------------------------------------
private:
        
#if defined(_WIN32) | defined(__WIN32__) | defined(__WIN32) | defined(_WIN64) | defined(__WIN64)
    HANDLE map_handle;
#else
    int32_t map_handle;
#endif
        
    void* map_address;

    std::string name;
    
    uint64_t data_size;

// ----------------------------------------------------------------------------           
    inline void read_data(uint64_t position, uint8_t& data)
    {
        data = *((uint8_t*)(map_address)+position);
    }   // end of read_data
            
    inline void write_data(uint64_t position, uint8_t data)
    {
        uint8_t* d = ((uint8_t*)(map_address)+position);
        *d = data;
    }   // end of write_data


};   // end of class

#endif  // _MMAP_H_
