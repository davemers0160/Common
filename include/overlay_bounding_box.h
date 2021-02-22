#ifndef OVERLAY_BBOX_H_
#define OVERLAY_BBOX_H_


#include <opencv2/core/core.hpp>
#include <opencv2/imgproc.hpp>


// ----------------------------------------------------------------------------------------
void overlay_bounding_box(cv::Mat &img, cv::Rect box_rect, std::string label, cv::Scalar color, bool show_label = true)
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

    if (show_label)
    {
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
        cv::rectangle(img, label_pos, label_pos + cv::Point(text_size.width, text_size.height + 4), color, -1);
        cv::putText(img, label, label_pos + cv::Point(0, (text_size.height + 3)), font_face, font_scale, cv::Scalar(0, 0, 0), thickness, cv::LINE_8, false);
    }

}   // end of overlay_bounding_box

// ----------------------------------------------------------------------------------------
void overlay_bounding_box(uint8_t *src, 
    int h, int w, int c,
    int rx, int ry, int rw, int rh,
    char* label, 
    unsigned char r, unsigned char g, unsigned char b,
    bool show_label
    )
{
    cv::Mat img;
    
    switch(c)
    {
    case 1:
        img = cv::Mat(h, w, CV_8UC1, src, w * sizeof(*src));
        break;
    case 3:
        img = cv::Mat(h, w, CV_8UC3, src, c * w * sizeof(*src));
        break;
    }
        
    overlay_bounding_box(img, cv::Rect(rx, ry, rw, rh), std::string(label), cv::Scalar(b,g,r), show_label);
    
}   // end of overlay_bounding_box


#endif  // OVERLAY_BBOX_H_
