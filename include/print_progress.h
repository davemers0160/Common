#ifndef PRINT_PROGRESS_H_
#define PRINT_PROGRESS_H_

#include <cstdint>
#include <string>
#include <iostream>
#include <iomanip>


// ----------------------------------------------------------------------------------------

void print_progress(float progress)
{
    uint32_t bar_width = 70;

    if (progress == 0.0)
    {
        std::cout << "[" << std::string(bar_width, ' ') << "] " << std::fixed << std::setprecision(2) << (progress * 100.0) << "%\r";
        std::cout.flush();
        return;
    }

    if (progress <= 1.0)
    {
        
        uint32_t bar_count = (uint32_t)(bar_width* progress);

        std::cout << "[" << std::string(bar_count, '=') << std::string(bar_width-bar_count, ' ') << "] " << std::fixed << std::setprecision(2) << (progress * 100.0) << "%\r";
        std::cout.flush();
    }

}

#endif  // PRINT_PROGRESS_H_
