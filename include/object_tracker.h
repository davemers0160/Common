#ifndef _OBJ_TRACKER_H_
#define _OBJ_TRACKER_H_

#include <cstdint>
#include <vector>
#include <string>


template <typename image_type>
struct detect
{
	uint64_t x;
	uint64_t y;
	uint64_t w;
	uint64_t h;
	
	image_type image;
	
	std::string time_stamp;
	
	bool detection;
}


class object_tracker
{

private:
	std::string uuid;
	
	
public:
	

};	// end of object_detection


#endif	// _OBJ_TRACKER_H_
