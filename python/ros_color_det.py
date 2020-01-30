import os
import sys
import math
import rospy
import message_filters
from sensor_msgs.msg import Image, CameraInfo
from std_msgs.msg import String
from cv_bridge import CvBridge
import cv2
import numpy as np


class color_detector():
    def __init__(self):

        self._cv_bridge = CvBridge()

        # define the list of color boundaries
        self.boundaries = [
	        ([17, 15, 100], [50, 56, 200]),
	        ([86, 31, 4], [220, 88, 50]),
	        ([25, 146, 190], [62, 174, 250]),
	        ([103, 86, 65], [145, 133, 128])]

        self.image_sub = message_filters.Subscriber('/zed/zed_node/rgb/image_rect_color', Image, queue_size=1)
        self.depth_sub = message_filters.Subscriber('/zed/zed_node/depth/depth_registered', Image, queue_size=1)
        self.cam_info_sub = rospy.Subscriber('/zed/zed_node/rgb/camera_info', CameraInfo, self.camera_info, queue_size=1)

        ts = message_filters.TimeSynchronizer([self.image_sub, self.depth_sub], 10)
        ts.registerCallback(self.callback)

        self._mask_pub = rospy.Publisher('color_det/image_mask', Image, queue_size=1)
        self._razel_pub = rospy.Publisher('color_det/target_razel', String, queue_size=1)


    def callback(self, image_msg, depth_msg):
        cv_image = self._cv_bridge.imgmsg_to_cv2(image_msg, "bgr8")
        depth_img = self._cv_bridge.imgmsg_to_cv2(depth_msg)

        # converting from BGR to HSV color space
        hsv = cv2.cvtColor(cv_image, cv2.COLOR_BGR2HSV)

        # Range for lower red
        lower_red = np.array([0,120,70])
        upper_red = np.array([10,255,255])
        mask1 = cv2.inRange(hsv, lower_red, upper_red)
 
        # Range for upper red
        lower_red = np.array([170,120,70])
        upper_red = np.array([180,255,255])
        mask2 = cv2.inRange(hsv,lower_red,upper_red)
 
        # Generating the final mask to detect red color
        kernel = np.ones((5,5),np.uint8)
        mask = mask1 + mask2
#       mask = cv2.morphologyEx(mask, cv2.MORPH_OPEN, kernel)
        mask = cv2.morphologyEx(mask, cv2.MORPH_DILATE, kernel)
        mask = cv2.morphologyEx(mask, cv2.MORPH_OPEN, kernel)

        # loop over the boundaries
        #for (lower, upper) in self.boundaries:
	#        # create NumPy arrays from the boundaries
	#        lower = np.array(lower, dtype = "uint8")
	#        upper = np.array(upper, dtype = "uint8")

	        # find the colors within the specified boundaries and apply the mask
	#        mask = cv2.inRange(cv_image, lower, upper)
	#        output = cv2.bitwise_and(cv_image, cv_image, mask=mask)

	        # show the images
	#        cv2.imshow("images", np.hstack([cv_image, output]))
	#        cv2.waitKey(0)
		
	output = cv2.bitwise_and(cv_image, cv_image, mask=mask)
	output = np.hstack([cv_image, hsv, output])
        self._mask_pub.publish(self._cv_bridge.cv2_to_imgmsg(output, "bgr8"))


    def camera_info(self, data):
        self.img_h = data.height
        self.img_w = data.width
        self.h_res = 90.0/self.img_w
        self.v_res = 60.0/self.img_h
        print("\ncam info:")
        print("Image Size (h x w): {} x {}".format(self.img_h, self.img_w))
        print("Angular Resolution (AZ, EL): {}, {}\n".format(self.h_res, self.v_res))
        self.cam_info_sub.unregister()
    
    def main(self):
        rospy.spin()


if __name__ == '__main__':
    #classify_image.setup_args()
    rospy.init_node('color_detector')
    color_det = color_detector()
    color_det.main()
