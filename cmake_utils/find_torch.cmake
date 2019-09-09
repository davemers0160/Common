message(" ")
message(STATUS "Looking for LibTorch Library...")

set(Torch_DIR "$ENV{Torch_DIR}" CACHE INTERNAL "Copied from environment variable")

message("Torch_DIR: " ${Torch_DIR})

find_path(Torch_INCLUDE_DIRS torch.h
    PATHS /usr/local ${Torch_DIR}/torch/csrc/api "D:/pytorch/torch/csrc/api/include/torch" ENV CPATH 
    #PATH_SUFFIXES include/torch
    ) 
    
message("Torch_INCLUDE_DIRS: " ${Torch_INCLUDE_DIRS})    
    
find_library(TORCH_LIBRARIES torch
    HINTS ${Torch_DIR}
    PATHS /usr/local ${Torch_DIR}/build/lib
    PATH_SUFFIXES Debug Release 
    )
    
message("TORCH_LIBRARIES: " ${TORCH_LIBRARIES})  
    
mark_as_advanced(TORCH_LIBRARIES Torch_INCLUDE_DIRS)

if (TORCH_LIBRARIES AND Torch_INCLUDE_DIRS)
    set(Torch_FOUND TRUE)
else()
    message(STATUS "--- Torch not found! ---")
    set(Torch_FOUND FALSE)
endif()
message(" ")
