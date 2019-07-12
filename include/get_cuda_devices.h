
#include <cstdint>
#include <sstream>
#include <string>
#include <vector>

#include "dlib/dnn.h"


typedef struct cuda_device_info
{
    int32_t device_count;
    std::vector<std::string> device_names;
} cuda_device_info;

cuda_device_info get_cuda_devices(void)
{
    cuda_device_info dev;
    dev.device_names.clear();
    
    dev.device_count = dlib::cuda::get_num_devices();
    //std::cout << "Total Attached Cuda Devices: " << total_devices << std::endl;

    for (int32_t idx = 0; idx < dev.device_count; ++idx)
    {
        //std::cout << "Device Name: " << dlib::cuda::get_device_name(idx) << std::endl;
        dev.device_names.push_back(dlib::cuda::get_device_name(idx));
    }

    return dev;
}

//-----------------------------------------------------------------

inline std::ostream& operator<< (std::ostream& out, const cuda_device_info& item)
{
    out << "Cuda Device Info: " << std::endl;
    out << "  Total Attached Cuda Devices: " << item.device_count << std::endl;   
    for(int32_t idx=0; idx<item.device_count; ++idx)
        out << "  Device Name: " << item.device_names[idx] << std::endl;

    return out;
}

