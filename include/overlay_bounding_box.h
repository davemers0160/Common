#ifndef OVERLAY_BBOX_H_
#define OVERLAY_BBOX_H_


#include <opencv2/core/core.hpp>
#include <opencv2/imgproc.hpp>

#include <dlib/pixel.h>
#include <dlib/image_transforms.h>
#include <dlib/image_processing.h>
#include <dlib/opencv.h>

// ----------------------------------------------------------------------------------------

void overlay_bounding_box(cv::Mat &img, cv::Rect box_rect, std::string label, cv::Scalar color)
{

    //int font_face = cv::FONT_HERSHEY_SIMPLEX;
    int font_face = cv::FONT_HERSHEY_PLAIN;
    int thickness = 1;
    int baseline = 0;
    double font_scale = 1.0;
    cv::Point label_pos;

    // get the text size
    cv::Size text_size = cv::getTextSize(label, font_face, font_scale, thickness, &baseline);

    // draw the bounding box
    cv::rectangle(img, box_rect, color, 2, cv::LINE_8);

    // add some logic to place the text in the right location
    // check the x coord
    if ((box_rect.x + text_size.width - 1) > img.cols)
        //label_pos.x = box_rect.width - text_size.width;
        label_pos.x = img.cols - text_size.width - 1;
    else
        label_pos.x = box_rect.x - 1;

    // check the y coord
    if ((box_rect.y - (text_size.height + 3)) < 0)
        label_pos.y = box_rect.height + text_size.height + 3;
    else
        label_pos.y = box_rect.y - (text_size.height + 3);


    // put the text in the bounding box
    //cv::rectangle(img, box_rect.tl(), box_rect.tl() + cv::Point(text_size.width + 2, text_size.height + 4), color, -1);
    cv::rectangle(img, label_pos, label_pos + cv::Point(text_size.width, text_size.height + 4), color, -1);
    cv::putText(img, label, label_pos + cv::Point(0,(text_size.height+3)), font_face, font_scale, cv::Scalar(0, 0, 0), thickness, cv::LINE_8, false);

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
