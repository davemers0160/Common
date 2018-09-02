#ifndef PATH_CHECK_H_
#define PATH_CHECK_H_

#include "string"


void path_check(std::string &path)
{
    std::string path_sep = path.substr(path.length() - 1, 1);
    if (path_sep != "\\" & path_sep != "/")
    {
        path = path + "/";
    }

}   // end of path_check

#endif  // PATH_CHECK_H_
