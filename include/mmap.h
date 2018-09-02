#ifndef _MMAP_H_
#define _MMAP_H_

#if defined(_WIN32) | defined(__WIN32__) | defined(__WIN32) | defined(_WIN64) | defined(__WIN64)
#include <windows.h>
#else
#include <fcntl.h>
#include <unistd.h>
#include <sys/mman.h>
#include <sys/stat.h>
#endif

#include <stdexcept>
#include <streambuf>
#include <cstdint>
#include <string>
#include <vector>
#include <cmath>

#if defined(_WIN32) | defined(__WIN32__) | defined(__WIN32) | defined(_WIN64) | defined(__WIN64)
#define MAP_FAILED NULL
#endif

namespace mmap
{
    class MMap_File
    {
        public:
            
            MMap_File() 
            {
            #if defined(_WIN32) | defined(__WIN32__) | defined(__WIN32) | defined(_WIN64) | defined(__WIN64)          
                file_handle_ = NULL;
                map_handle_ = NULL;
            #else
                file_handle_ = -1;
            #endif
                file_size_ = 0;
                map_address_ = MAP_FAILED;
            }

            void open(std::string file_name)
            {
                
            #if defined(_WIN32) | defined(__WIN32__) | defined(__WIN32) | defined(_WIN64) | defined(__WIN64)
                file_handle_ = ::CreateFile(
                    file_name.c_str(),
                    GENERIC_READ | GENERIC_WRITE,
                    FILE_SHARE_READ | FILE_SHARE_WRITE,
                    NULL,
                    OPEN_ALWAYS,
                    FILE_ATTRIBUTE_NORMAL,
                    NULL);

                if (file_handle_ == INVALID_HANDLE_VALUE) 
                {
                    std::runtime_error("");
                }

                file_size_ = ::GetFileSize(file_handle_, NULL);

                map_handle_ = ::CreateFileMapping(file_handle_, NULL, PAGE_READWRITE, 0, 0, NULL);

                if (map_handle_ == NULL) 
                {
                    
                    close();
                    std::runtime_error("");
                }

                map_address_ = ::MapViewOfFile(map_handle_, FILE_MAP_ALL_ACCESS, 0, 0, 0);
                
            #else
                file_handle_ = open(path, O_RDWR | O_CREAT | O_TRUNC);
                if (file_handle_ == -1)
                {
                    std::runtime_error("");
                }

                struct stat sb;
                if (fstat(file_handle_, &sb) == -1)
                {
                    close();
                    std::runtime_error("");
                }
                file_size_ = sb.st_size;

                map_address_ = mmap(NULL, file_size_, PROT_READ | PROT_WRITE, MAP_SHARED, fd_, 0);
                
            #endif

                if (map_address_ == MAP_FAILED) 
                {
                    close();
                    std::runtime_error("");
                }                
                                         
            }   // end of open
            
// ----------------------------------------------------------------------------------------
                  
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

            if (file_handle_ != INVALID_HANDLE_VALUE) 
            {
                ::CloseHandle(file_handle_);
                file_handle_ = INVALID_HANDLE_VALUE;
            }
            
        #else
            if (map_address_ != MAP_FAILED) 
            {
                munmap(map_address_, size_);
                map_address_ = MAP_FAILED;
            }

            if (file_handle_ != -1) 
            {
                close(file_handle_);
                file_handle_ = -1;
            }

        #endif

            file_size_ = 0;

        }   // end of close
        
// ----------------------------------------------------------------------------------------

        inline void read_uint8(uint64_t &position, uint8_t &data_out)
        {
            data_out = *((uint8_t *)(map_address_)+position);
            ++position;
        }   // end of read

        template <typename T>
        inline void read(uint64_t &position, T &data_out)
        {
            //data_out = (*((uint8_t *)(map_address_)+position)) << 8 | *((uint8_t *)(map_address_)+position+1);
            data_out = 0;
            uint8_t tmp = 0;
            for (int8_t idx = sizeof(T)-1; idx >= 0; --idx)
            {
                read_uint8(position, tmp);
                data_out |= (tmp) << (8 * idx);
            }
        }
/*
        inline void read(uint64_t &position, uint32_t &data_out)
        {
            //data_out = (uint32_t)(((*((uint8_t *)(map_address_)+position)) << 24) | ((*((uint8_t *)(map_address_)+position+1)) << 16) | \
            //    ((*((uint8_t *)(map_address_)+position+2)) << 8) | *((uint8_t *)(map_address_)+position + 3));

            data_out = 0;
            uint8_t tmp = 0;
            for (int8_t idx = sizeof(uint32_t) - 1; idx >= 0; --idx)
            {
                read(position, tmp);
                data_out |= (tmp) << (8 * idx);
            }
        }

        inline void read(uint64_t &position, uint64_t &data_out)
        {
            //data_out = (uint64_t)(((uint64_t)(*((uint8_t *)(map_address_)+position)) << 56) | ((uint64_t)(*((uint8_t *)(map_address_)+position + 1)) << 48) | \
            //    ((uint64_t)(*((uint8_t *)(map_address_)+position+2)) << 40) | ((uint64_t)(*((uint8_t *)(map_address_)+position + 3)) << 32) | \
            //    ((uint64_t)(*((uint8_t *)(map_address_)+position+4)) << 24) | ((uint64_t)(*((uint8_t *)(map_address_)+position + 5)) << 16) | \
            //    ((uint64_t)(*((uint8_t *)(map_address_)+position + 6)) << 8) | (uint64_t)(*((uint8_t *)(map_address_)+position + 7)));
            
            data_out = 0;
            uint8_t tmp = 0;
            for (int8_t idx = sizeof(uint64_t) - 1; idx >= 0; --idx)
            {
                read(position, tmp);
                data_out |= (tmp) << (8 * idx);
            }
        }
*/

// ----------------------------------------------------------------------------------------

        inline void read_range(uint64_t &position, uint64_t length, std::vector<uint8_t> &data_out)
        {
            
            if (position + length >= file_size_)
                return;

            data_out.clear();
            
            for(uint64_t idx=0; idx<length; ++idx)
            {
                uint8_t d;
                read(position, d);
                data_out.push_back(d);       
            }         
            
        }   // end of read_range

// ----------------------------------------------------------------------------------------

        inline void write(uint64_t &position, uint8_t data)
        {
            if (position >= file_size_)
                return; 
            
            uint8_t *d = ((uint8_t *)(map_address_) + position);
            *d = data;
            ++position;

        }   // end of write


        template <typename T>
        inline void write(uint64_t &position, T data)
        {
            if (position + sizeof(T) >= file_size_)
                return; 
            for (int8_t idx = sizeof(T) - 1; idx >= 0; --idx)
            {
                write(position, (uint8_t)((data >> (8*idx)) & 0x00FF));
            }
            //write(position, (uint8_t)((data >> 8) & 0x00FF));
            //write(position, (uint8_t)(data & 0x00FF));
        }   // end of write


/*
        inline void write(uint64_t &position, uint32_t data)
        {
            if (position + sizeof(uint32_t) >= file_size_)
                return; 
            
            write(position, (uint16_t)((data >> 16) & 0x00FFFF));
            write(position, (uint16_t)(data & 0x00FFFF));
        }   // end of write

        inline void write(uint64_t &position, uint64_t data)
        {
            if (position + sizeof(uint64_t) >= file_size_)
                return;

            write(position, (uint32_t)((data >> 32) & 0x00FFFFFFFF));
            write(position, (uint32_t)(data & 0x00FFFFFFFF));
        }   // end of write   
*/
        inline void write(uint64_t &position, float data)
        {
            const uint32_t digits = std::numeric_limits<float>::digits;
            int32_t exponent;
            uint32_t mantissa;

            if (position + sizeof(float) >= file_size_)
                return;

            mantissa = static_cast<uint16_t>(std::frexp(data, &exponent)*(((uint64_t)1) << digits));
            exponent -= digits;

            write(position, (uint16_t)(exponent));
            write(position, (uint32_t)(mantissa));

        }

        inline void write(uint64_t &position, double data)
        {

            const uint32_t digits = std::numeric_limits<double>::digits;
            int32_t exponent;
            uint64_t mantissa;

            if (position + sizeof(double) >= file_size_)
                return;

            mantissa = static_cast<uint16_t>(std::frexp(data, &exponent)*(((uint64_t)1) << digits));
            exponent -= digits;

            write(position, (uint16_t)(exponent));
            write(position, (uint64_t)(mantissa));

        }

// ----------------------------------------------------------------------------------------

        inline void write_range(uint64_t &position, std::vector<uint8_t> data)
        {
            if (position+data.size() >= file_size_)
                return;

            for (uint64_t idx = 0; idx < data.size(); ++idx)
            {
                write(position, data[idx]);
            }
        }

// ----------------------------------------------------------------------------------------

        private:
        
        #if defined(_WIN32) | defined(__WIN32__) | defined(__WIN32) | defined(_WIN64) | defined(__WIN64)
            HANDLE file_handle_;
            HANDLE map_handle_;
        #else
            int32_t file_handle_;
        #endif
        
            uint64_t file_size_;
            void* map_address_;


    };   // end of class


}  // end of namespace

#endif  // _MMAP_H_
