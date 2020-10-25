message(STATUS "--------------------------------------------------------------------------------")
message(STATUS "Looking for EDT PDV library...")

find_path(EDTPDV_INCLUDE_DIRS edtinc.h
    PATHS /usr/local /opt/edt "C:/Program Files/EDT/PDV"  "C:/EDT/PDV" ENV CPATH 
    )

find_library(EDTPDV_LIBS pdvlib
    HINTS ${EDTPDV_INCLUDE_DIRS}
    PATHS /usr/local /opt/edt "C:/Program Files/EDT/PDV"  "C:/EDT/PDV"
    PATH_SUFFIXES lib bin/amd64 lib64 x64 
    )
    
mark_as_advanced(EDTPDV_LIBS EDTPDV_INCLUDE_DIRS)

if (EDTPDV_LIBS AND EDTPDV_INCLUDE_DIRS)
    set(EDTPDV_FOUND TRUE)
	add_compile_definitions(USE_EDTPDV)
	message(STATUS "Found EDT PDV Library: " ${EDTPDV_LIBS})
else()
    message("--- EDT PDV library was not found! ---")
    message("--- Library can be found at https://edt.com/file-category/pdv/ ---")
    set(EDTPDV_FOUND FALSE)
endif()

message(STATUS "--------------------------------------------------------------------------------")
message(STATUS " ")
