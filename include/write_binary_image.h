#ifndef _WRITE_BINARY_LIDAR_DATA_H
#define _WRITE_BINARY_LIDAR_DATA_H

#include <cstdint>
#include <cstdio>

void write_binary_image(std::string filename, cv::Mat img)
{
    FILE* FP = fopen(filename.c_str(), "wb");
    size_t result = 0;

    // read num of rows then num of cols
    result = fwrite(&img.rows, sizeof(uint32_t), 1, FP);
    result = fwrite(&img.cols, sizeof(uint32_t), 1, FP);

    result = fwrite(img.data, sizeof(img.elemSize1()), (img.rows*img.cols), FP);

    fclose(FP);

}

#endif	// _WRITE_BINARY_LIDAR_DATA_H