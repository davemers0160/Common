message(STATUS "--------------------------------------------------------------------------------")
message(STATUS "Looking for bladeRF library...")

find_path(BLADERF_INCLUDE_DIRS libbladeRF.h
    PATHS /usr/local "C:/Program Files/bladeRF" ENV CPATH 
    PATH_SUFFIXES include
    )

find_library(BLADERF_LIBS bladeRF
    HINTS ${BLADERF_INCLUDE_DIRS}
    PATHS /usr/local "C:/Program Files/bladeRF"
    PATH_SUFFIXES lib amd64 lib64 x64 
    )
    
mark_as_advanced(BLADERF_LIBS BLADERF_INCLUDE_DIRS)

if (BLADERF_LIBS AND BLADERF_INCLUDE_DIRS)
    set(BLADERF_FOUND TRUE)
	add_compile_definitions(USE_BLADERF)
	message(STATUS "Found bladeRF Library: " ${BLADERF_LIBS})
else()
    message("--- bladeRF library was not found! ---")
    message("--- Library can be found at https://www.nuand.com/support/ ---")
    set(BLADERF_FOUND FALSE)
endif()

message(STATUS "--------------------------------------------------------------------------------")
