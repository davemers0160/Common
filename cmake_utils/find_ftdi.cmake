message(" ")
message(STATUS "Looking for FTDI drivers...")
# Look for FTDI Drivers

find_path(FTDI_INCLUDE_DIRS ftd2xx.h
    PATHS /usr/local "D:/CDM v2.12.28 WHQL Certified" "C:/CDM v2.12.28 WHQL Certified" ENV CPATH 
    PATH_SUFFIXES include
    )

find_library(FTDI_LIBS ftd2xx
    HINTS ${FTDI_INCLUDE_DIRS}
    PATHS /usr/local "D:/CDM v2.12.28 WHQL Certified" "C:/CDM v2.12.28 WHQL Certified"
    PATH_SUFFIXES amd64 lib64 x64 
    )
mark_as_advanced(FTDI_LIBS FTDI_INCLUDE_DIRS)

if (FTDI_LIBS AND FTDI_INCLUDE_DIRS)
    set(FTDI_FOUND TRUE)
else()
    message("--- FTDI drivers were not found! ---")
    set(FTDI_FOUND FALSE)
endif()
