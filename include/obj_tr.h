#ifndef _OBJ_TR_H_
#define _OBJ_TR_H_


// C++ Includes
#include <cstdint>
#include <vector>
#include <string>
#include <algorithm>

// OpenCV Includes
#include <opencv2/core.hpp>           
#include <opencv2/highgui.hpp>     
#include <opencv2/imgproc.hpp> 

// Custom Includes
#include "get_current_time.h"

// ----------------------------------------------------------------------------------------
typedef struct
{
    uint64_t x;
    uint64_t y;
    uint64_t w;
    uint64_t h;
    std::string label;
    std::string date_time;
    cv::Mat img;
    bool detection;

} dets;

// ----------------------------------------------------------------------------------------

class object
{
public:

    object() {}

    object(uint64_t TDD_)
    {
        TDD = TDD_;
        detects.resize(TDD);
        velocity.resize(TDD);
    }

    uint64_t generate_track_id(void);
    {
        return 0;
    }

    void set_TDD(uint64_t TDD_) : TDD(TDD_) {}

    void set_TDD_counter(uint64_t TTD_counter_) : TTD_counter(TTD_counter_) {}


private:

    std::vector<dets> detects;
    std::vector<std::pair<double, double>> velocity;

    uint64_t TTD;
    uint64_t TTD_counter;

    uint64_t track_id;



};  // end of class





#endif  // _OBJECT_TRACKER_H_