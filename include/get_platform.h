#ifndef GET_PLATFORM_H
#define GET_PLATFORM_H

// this function looks for the PLATFORM environment variable
// the variable should be set for every system
// windows: setx PLATFORM Laptop or setx PLATFORM Alienware
// linux: export PLATFORM=HPC or PLATFORM=MainGear
// this is going to be used to help resolve merge conflicts between various
// hardware/software platforms running the training code

#include <cstdlib>
#include <string>

using namespace std;

//--------------------------------------------------------

std::string get_env_variable(std::string env_var)
{
    char* p;
    p = getenv(env_var.c_str());

    if (p == NULL)
        return "";
    else
        return std::string(p);
}

//--------------------------------------------------------

void get_platform(std::string &platform)
{
    platform = get_env_variable("PLATFORM");
}

#endif  // GET_PLATFORM_H