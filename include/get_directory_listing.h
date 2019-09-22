#pragma once

#if defined(_WIN32) | defined(__WIN32__) | defined(__WIN32) | defined(_WIN64) | defined(__WIN64)

#elif defined(__linux__) 
#include <dirent.h> 
#include <sys/stat.h> 
#endif


// ----------------------------------------------------------------------------------------
// https://stackoverflow.com/questions/612097/how-can-i-get-the-list-of-files-in-a-directory-using-c-or-c
std::vector<std::string> get_directory_listing(std::string folder)
{
    std::vector<std::string> file_names;
    std::string search_path = folder + "*.*";

#if defined(_WIN32) | defined(__WIN32__) | defined(__WIN32) | defined(_WIN64) | defined(__WIN64)

    WIN32_FIND_DATA fd;
    void* hFind = ::FindFirstFile(search_path.c_str(), &fd);

    if (hFind != INVALID_HANDLE_VALUE)
    {
        do
        {
            // read all (real) files in current folder
            // , delete '!' read other 2 default folder . and ..
            if (!(fd.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY)) 
            {
                file_names.push_back(fd.cFileName);
            }
        } while (::FindNextFile(hFind, &fd));
        ::FindClose(hFind);
    }

#elif defined(__linux__) 
// https://stackoverflow.com/questions/306533/how-do-i-get-a-list-of-files-in-a-directory-in-c
    DIR* dir;
    class dirent* ent;
    class stat st;

    dir = opendir(folder.c_str());
    while ((ent = readdir(dir)) != NULL) 
    {
        const string file_name = ent->d_name;
        //const string full_file_name = directory + "/" + file_name;

        if (file_name[0] == '.')
            continue;

        if (stat((search_path + file_name).c_str(), &st) == -1)
            continue;

        const bool is_directory = (st.st_mode & S_IFDIR) != 0;

        if (is_directory)
            continue;

        file_names.push_back(file_name); // returns just filename
    }
    closedir(dir);
#endif

    return file_names;
}

