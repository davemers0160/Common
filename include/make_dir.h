#ifndef _MAKE_DIR_HEADER_H_
#define _MAKE_DIR_HEADER_H_

#if defined(_WIN32) | defined(__WIN32__) | defined(__WIN32) | defined(_WIN64) | defined(__WIN64)
	#include <Windows.h>
#elif defined(__linux__)
// The system cannot find the path specified
    #define ERROR_PATH_NOT_FOUND 3L
// Cannot create a file when that file already exists
    #define ERROR_ALREADY_EXISTS 183L

	#include <sys/stat.h>
#endif

#include <cstdint>
#include <string>
#include <vector>

#include "file_parser.h"

// ----------------------------------------------------------------------------------------

void separate_paths(std::string full_path, std::vector<std::string>& path_list)
{
    const char* sep = "/\\";
    std::size_t file_sep = full_path.find_first_of(sep);

    if (file_sep > full_path.length())
        return;

    do
    {
        path_list.push_back(full_path.substr(0, file_sep));
        full_path = full_path.substr(file_sep + 1, full_path.length() - 1);
        file_sep = full_path.find_first_of(sep);
    } while (file_sep < full_path.length());

    if (full_path.length() > 0)
    {
        path_list.push_back(full_path);
    }

}

// ----------------------------------------------------------------------------
int32_t make_dir(std::string full_path)
{
    int32_t status = -1;

#if defined(_WIN32) | defined(__WIN32__) | defined(__WIN32) | defined(_WIN64) | defined(__WIN64)

    wstring w_fp = wstring(full_path.begin(), full_path.end());
    status = (int32_t)CreateDirectoryW(w_fp.c_str(), NULL);
    if (status < 1)
    {
        status = GetLastError();
    }
#elif defined(__linux__)

    mode_t mode = 0766;
    status = mkdir(full_path.c_str(), mode);

#endif

    return status;
}

// ----------------------------------------------------------------------------
int32_t make_dir(std::string directory_path, std::string new_folder)
{

    int32_t status = -1;
    directory_path = path_check(directory_path);
    
	std::string full_path = directory_path + new_folder;

    status = make_dir(full_path);

    /*
#if defined(_WIN32) | defined(__WIN32__) | defined(__WIN32) | defined(_WIN64) | defined(__WIN64)

	wstring full_path = wstring(temp_path.begin(), temp_path.end());
	status = (int32_t)CreateDirectoryW(full_path.c_str(), NULL);
    //if (status < 1)
    //{
        status = GetLastError();
    //}
#elif defined(__linux__)

	mode_t mode = 0766;
	status = mkdir(temp_path.c_str(), mode);

#endif
*/
    return status;
    
}	// end of make_dir

// ----------------------------------------------------------------------------
int32_t recursive_mkdir(std::string full_path)
{
    int32_t status = -1;
    bool check;
    std::string test_path = "";
    std::vector<std::string> path_list;

    separate_paths(full_path, path_list);

    for (auto s : path_list)
    {
        test_path = test_path + s + "/";
        check = existence_check(test_path);

        if (check == false)
            status = make_dir(test_path);
    }

    return status;
}

// ----------------------------------------------------------------------------

#endif  //_MAKE_DIR_HEADER_H_
