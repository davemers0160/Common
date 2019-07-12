#ifndef _READ_BINARY_LIDAR_DATA_H
#define _READ_BINARY_LIDAR_DATA_H


#include <cstdint>
#include <cstdio>

void read_binary_lidar_data(std::string filename, uint32_t &width, uint32_t &height, int32_t* &data)
{
    FILE* FP = fopen(filename.c_str(), "rb");
    int32_t result = 0;

    result = fread(&width, sizeof(uint32_t), 1, FP);
    result = fread(&height, sizeof(uint32_t), 1, FP);

    data = new int32_t[width*height];

    result = fread(data, sizeof(int32_t), width*height, FP);

    fclose(FP);

}

#endif	// _READ_BINARY_LIDAR_DATA_H