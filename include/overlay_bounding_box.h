#ifndef OVERLAY_BBOX_H_
#define OVERLAY_BBOX_H_


#include <opencv2/core/core.hpp>

//#include <dlib/matrix.h>
#include <dlib/pixel.h>
//#include <dlib/image_io.h>
#include <dlib/image_transforms.h>
#include <dlib/image_processing.h>

// ----------------------------------------------------------------------------------------

void overlay_bounding_box(cv::Mat &img, cv::Rect box_rect, std::string label, cv::Scalar color)
{

    //int font_face = cv::FONT_HERSHEY_SIMPLEX;
    int font_face = cv::FONT_HERSHEY_PLAIN;
    int thickness = 1;
    int baseline = 0;
    double font_scale = 1.0;

    // get the text size
    cv::Size text_size = cv::getTextSize(label, font_face, font_scale, thickness, &baseline);

    // draw the bounding box
    cv::rectangle(img, box_rect, color, 2, cv::LINE_8);

    // put the text in the bounding box
    cv::rectangle(img, box_rect.tl(), box_rect.tl() + cv::Point(text_size.width + 2, text_size.height + 4), color, -1);
    cv::putText(img, label, box_rect.tl() + cv::Point(1, text_size.height + 3), font_face, font_scale, cv::Scalar(0, 0, 0), thickness, cv::LINE_8, false);

}   // end of overlay_bounding_box

// ----------------------------------------------------------------------------------------

template<typename image_type>
void overlay_bounding_box(image_type &img, dlib::mmod_rect box_label, dlib::rgb_pixel color)
{

    cv::Scalar c(color.blue, color.green, color.red);
    cv::Rect r(box_label.rect.left(), box_label.rect.top(), box_label.rect.width(), box_label.rect.height());

    overlay_bounding_box(dlib::toMat(img), r, box_label.label, c);


}


#endif  // OVERLAY_BBOX_H_
