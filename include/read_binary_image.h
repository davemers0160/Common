#ifndef _READ_BINARY_LIDAR_DATA_H
#define _READ_BINARY_LIDAR_DATA_H


#include <cstdint>
#include <cstdio>

template <typename T>
void read_binary_image(std::string filename, uint32_t &height,  uint32_t &width, T* &data)
{
	try
	{
		FILE* FP = fopen(filename.c_str(), "rb");
		int32_t result = 0;
		
		height = 0;
		width = 0;
		
		if(!FP) 
		{
			std::perror("File opening failed");
            std::cout << filename << std::endl;
			return;
		}
		
		// read num of rows then num of cols
		result = fread(&height, sizeof(uint32_t), 1, FP);
		result = fread(&width, sizeof(uint32_t), 1, FP);


		data = new T[width*height];

		result = fread(data, sizeof(T), width*height, FP);

		fclose(FP);
	}
	catch(std::exception e)
	{
		std::cout << "Error: " << e.what() << std::endl;
	}
}

#endif	// _READ_BINARY_LIDAR_DATA_H