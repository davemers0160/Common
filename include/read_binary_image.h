#ifndef _READ_BINARY_IMAGE_H
#define _READ_BINARY_IMAGE_H


#include <cstdint>
#include <cstdio>

template <typename T>
void read_binary_image(std::string filename, dlib::matrix<T> &img)
{
	try
	{
		FILE* FP = fopen(filename.c_str(), "rb");
		int32_t result = 0;
		
        uint32_t height = 0;
        uint32_t width = 0;
		
		if(!FP) 
		{
			std::perror("File opening failed");
            std::cout << filename << std::endl;
			return;
		}
		
		// read num of rows then num of cols
		result = fread(&height, sizeof(uint32_t), 1, FP);
		result = fread(&width, sizeof(uint32_t), 1, FP);

        //uint32_t *data = new uint32_t[width*height];
        T *data = new T[width*height];

		result = fread(data, sizeof(T), width*height, FP);

        //img = dlib::matrix_cast<T>(dlib::mat(data, height, width));
        img = dlib::mat(data, height, width);

        delete[] data;
        data = NULL;

		fclose(FP);
	}
	catch(std::exception e)
	{
		std::cout << "Error: " << e.what() << std::endl;
	}
}

#endif	// _READ_BINARY_LIDAR_DATA_H