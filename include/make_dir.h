#ifndef _MAKE_DIR_HEADER_H_
#define _MAKE_DIR_HEADER_H_

#if defined(_WIN32) | defined(__WIN32__) | defined(__WIN32) | defined(_WIN64) | defined(__WIN64)
	#include <Windows.h>
#else
	#include <sys/stat.h>
#endif

#include <cstdint>
#include <string>

#include "file_parser.h"


int32_t make_dir(std::string directory_path, std::string new_folder)
{

    int32_t status = -1;
    path_check(directory_path);
    
	std::string temp_path = directory_path + new_folder;

#if defined(_WIN32) | defined(__WIN32__) | defined(__WIN32) | defined(_WIN64) | defined(__WIN64)

	wstring full_path = wstring(temp_path.begin(), temp_path.end());
	status = (int32_t)CreateDirectoryW(full_path.c_str(), NULL);
    if (status < 1)
    {
        status = GetLastError();
    }
#else

	mode_t mode = 0766;
	status = mkdir(temp_path.c_str(), mode);

#endif

    return status;
    
}	// end of make_dir

#endif  //_MAKE_DIR_HEADER_H_