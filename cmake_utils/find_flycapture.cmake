message(" ")
message(STATUS "Looking for FlyCapture install...")
# Look for FlyCapture

find_path(FC2_INCLUDE_DIRS FlyCapture2.h
    HINTS ENV FC2PATH
    PATHS /usr/local "D:/Point Grey Research/FlyCapture2" "C:/Program Files/Point Grey Research/FlyCapture2" ENV CPATH 
    PATH_SUFFIXES include
    )
    
#get_filename_component(cudnn_hint_path "${CUDA_CUBLAS_LIBRARIES}" PATH)

find_library(FC2_LIBS FlyCapture2_v140
    HINTS ENV FC2PATH 
    PATHS /usr/local "D:/Point Grey Research/FlyCapture2" "C:/Program Files/Point Grey Research/FlyCapture2"
    PATH_SUFFIXES lib64/vs2015 lib x64
    )
mark_as_advanced(FC2_LIBS FC2_INCLUDE_DIRS)

if (FC2_LIBS AND FC2_INCLUDE_DIRS)
    set(FC2_FOUND TRUE)
else()
    message(STATUS "--- FlyCapture NOT FOUND. ---")
    set(FC2_FOUND FALSE)
endif()