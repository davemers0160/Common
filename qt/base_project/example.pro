lessThan(QT_MAJOR_VERSION, 6): message("Project requires Qt 6 as a minimum")

QT += core gui widgets

TARGET = example

CONFIG += c++17

INCLUDEPATH  += include \
                ../common/include

HEADERS      += $$PWD/include/mainwindow.h
          
SOURCES      += $$PWD/src/main.cpp \
                $$PWD/src/mainwindow.cpp
                
#RESOURCES    += $$PWD/icons/icon_resources.qrc

FORMS        += $$PWD/forms/mainwindow.ui

#DESTDIR = $$PWD/build
BUILDDIR = $$PWD/build

OBJECTS_DIR = $${BUILDDIR}
MOC_DIR = $${BUILDDIR}
RCC_DIR = $${BUILDDIR}
UI_DIR = $${BUILDDIR}

#------------------------------------------------------------------------------
# get the PLATFORM_ environment variable from the system
PM = $$(PLATFORM_)

if(isEmpty(PM)){
    message("!--- The PLATFORM_ Environment Variable is not set")

    # this is the default configuration
    CONFIG(debug, debug|release) { 
            LIBS += $$PWD/../../rapidyaml/build/Debug/ryml.lib
    }
    CONFIG(release, debug|release) { 
            LIBS += $$PWD/../../rapidyaml/build/Release/ryml.lib
    }
    
    INCLUDEPATH += $$PWD/../../Common/include \ 
                   $$PWD/../../rapidyaml/include 

} 
else 
{
    message("Platform:" $${PM})
}

#------------------------------------------------------------------------------
# check the PLATFORM_ env variable and assign the correct paths
contains(PM, "LaptopN") {

    # this sections check the build type Debog or Release and sets variables accordingly (needed to specifiy debug or release versions of a lib)
    CONFIG(debug, debug|release) { 
        LIBS += C:/Projects/rapidyaml/build/Debug/ryml.lib
    }
    CONFIG(release, debug|release) { 
        LIBS += C:/Projects/rapidyaml/build/Release/ryml.lib
    }

    INCLUDEPATH += C:/Projects/Common/include \ 
                   C:/Projects/rapidyaml/include 

}

contains(PM, "Laptop_Beast") {

    # this sections check the build type Debog or Release and sets variables accordingly (needed to specifiy debug or release versions of a lib)
    CONFIG(debug, debug|release) { 
        LIBS += D:/Projects/rapidyaml/build/Debug/ryml.lib
    }
    CONFIG(release, debug|release) { 
        LIBS += D:/Projects/rapidyaml/build/Release/ryml.lib
    }

    INCLUDEPATH += D:/Projects/Common/include \ 
                   D:/Projects/rapidyaml/include 
}

# Add aditional platforms here and adjust the paths accordingly

#------------------------------------------------------------------------------
message("------------------------------------------------------------------------------")
message("SOURCES")
for(a, SOURCES):message("    "$${a})
message(" ")

message("------------------------------------------------------------------------------")
message("INCLUDEPATH")
for(a, INCLUDEPATH):message("    "$${a})
message(" ")

message("------------------------------------------------------------------------------")
message("LIBS")
for(a, LIBS):message("    "$${a})
message(" ")

message("------------------------------------------------------------------------------")


# install
#target.path = $$[QT_INSTALL_EXAMPLES]/widgets/widgets/windowflags
#target.path = C:\Projects\Repos\widgets\windowflags2
#INSTALLS += target

