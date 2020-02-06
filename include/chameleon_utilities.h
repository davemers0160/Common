/*
Chameleon 3 Camera configuration file

This file contains the configures the routines for the Chameleon 3 camera. 

*/
#ifndef CHAMELEON_UTILITIES_H
#define CHAMELEON_UTILITIES_H

#include <cstdint>
#include <ctime>
#include <sstream>
#include <fstream>
#include <string>
#include <iomanip>
#include <vector>
#include <tuple>
#include <iostream>


#if defined(_WIN32) | defined(__WIN32__) | defined(__WIN32) | defined(_WIN64) | defined(__WIN64)
	#include <windows.h>
#ifdef USE_FC2
	#include "FlyCapture2.h"
#endif
#else
	#include <unistd.h>
	#include <time.h>
	//#include <linux/types.h>
	#include <sys/stat.h>
	#include "../Chameleon_Test_Linux/include/FlyCapture2.h"
#endif

#include "sleep_ms.h"

#ifdef USE_FC2
namespace FC2 = FlyCapture2;
#endif

// Chameleon 3 registers
const uint32_t TEMPERATURE = 0x082C;        // temperature register
const uint32_t CAMERA_POWER = 0x0610;       // camera power register


template<typename T>
struct cam_prop
{
    T value;
    bool auto_mode;
    bool on_off;
    bool abs_control;

    cam_prop() {}
    //cam_prop(T value_)
    //{
    //    value = value_;
    //}

    cam_prop(T value_, bool auto_mode_, bool on_off_, bool abs_control_)
    {
        value = value_;
        auto_mode = auto_mode_;
        on_off = on_off_;
        abs_control = abs_control_;
    }
};

struct cam_properties_struct {

    cam_prop<uint32_t> sharpness;
    cam_prop<float> shutter;
    cam_prop<float> gain;
    cam_prop<float> brightness;
    cam_prop<float> auto_exp;
    cam_prop<float> fps;

    cam_properties_struct() 
    {
        //sharpness = cam_prop<uint32_t>(0);
    }

    //std::tuple<uint32_t, bool, bool, bool> sharpness;
    //std::tuple<float, bool, bool, bool> shutter;
    //std::tuple<float, bool, bool, bool> gain;
    //std::tuple<float, bool, bool, bool> brightness;
    //std::tuple<float, bool, bool, bool> auto_exp;
    //std::tuple<float, bool, bool, bool> fps;

};


// ----------------------------------------------------------------------------------------
#ifdef USE_FC2
void print_error(FC2::Error error)
{
	error.PrintErrorTrace();
}
#else
void print_error(long error)
{
    error = -1;
}
#endif

// ----------------------------------------------------------------------------------------
#ifdef USE_FC2
inline std::ostream& operator<< (
    std::ostream& out,
    const FC2::CameraInfo& item
    )
{
    using std::endl;
	out << "Camera Information: " << std::endl;
	out << "  Serial number:       " << item.serialNumber << std::endl;
	out << "  Camera model:        " << item.modelName << std::endl;
	out << "  Camera vendor:       " << item.vendorName << std::endl;
	out << "  Sensor:              " << item.sensorInfo << std::endl;
	out << "  Resolution:          " << item.sensorResolution << std::endl;
	out << "  Bayer Tile Format:   " << item.bayerTileFormat << std::endl;
	out << "  Firmware version:    " << item.firmwareVersion << std::endl;
	out << "  Firmware build time: " << item.firmwareBuildTime << std::endl;
    return out;
}
#endif

// ----------------------------------------------------------------------------------------	

inline std::ostream& operator<< (
    std::ostream& out,
    const cam_properties_struct& item
    )
{
    using std::endl;
    out << "Camera Settings: " << std::endl;
    out << "  Shutter Speed (ms): " << item.shutter.value << std::endl;
    out << "  Brightness:         " << item.brightness.value << std::endl;
    out << "  Gain (dB):          " << item.gain.value << std::endl;
    out << "  Sharpness:          " << item.sharpness.value << std::endl;
    out << "  Exposure (EV):      " << item.auto_exp.value << std::endl;
    out << "  FPS:                " << item.fps.value << std::endl;
    return out;
}


// ----------------------------------------------------------------------------------------	

void print_build_info(void)
{
#ifdef USE_FC2
	FC2::FC2Version fc2Version;
	FC2::Utilities::GetLibraryVersion(&fc2Version);
    
    std::cout << "FlyCapture2 library version: " << fc2Version.major << "." << fc2Version.minor << "." << fc2Version.type << "." << fc2Version.build << std::endl;
    std::cout << "Application build date: " << __DATE__ << " " << __TIME__ << std::endl;
#endif

}	// end of PrintBuildInfo

// ----------------------------------------------------------------------------------------	
#ifdef USE_FC2
FC2::Error set_property(FC2::Camera &cam, FC2::Property &prop)
{
	FC2::Error error = cam.SetProperty(&prop);

	return error;
}	// end of setProperty

FC2::Error set_abs_property(FC2::Camera &cam, FC2::Property &prop, float value)
{
	FC2::Error error;

	prop.absValue = value;
	error = cam.SetProperty(&prop);

	return error;
}	// end of set_abs_property

FC2::Error set_int_property(FC2::Camera &cam, FC2::Property &prop, uint32_t value)
{
    FC2::Error error;

    prop.valueA = value;
    error = cam.SetProperty(&prop);

    return error;
}	// end of set_int_property

float get_abs_property(FC2::Camera &cam, FC2::Property &prop)
{
	float value = 0;

	cam.GetProperty(&prop);
	value = prop.absValue;

	return value;
}	// end of get_abs_property

int32_t get_property(FC2::Camera &cam, FC2::Property &prop)
{
	int value = 0;

	cam.GetProperty(&prop);
	value = prop.valueA;

	return value;
}	// end of getProperty

// ----------------------------------------------------------------------------------------

void camera_connect(FC2::PGRGuid guid, FC2::Camera &cam)
{
	FC2::Error error;
	//CameraInfo camInfo;

	error = cam.Connect(&guid);
	if (error != FC2::PGRERROR_OK)
	{
        print_error(error);
        //std::cout << error << std::endl;
	}

}	// end of camera_connect


FC2::Error config_imager_format(FC2::Camera &cam, uint32_t offsetX, uint32_t offsetY, uint32_t width, uint32_t height, FC2::PixelFormat pixelFormat)
{
    FC2::Format7Info fmt7Info;
    FC2::Format7ImageSettings CameraSettings;
    FC2::Format7PacketInfo PacketInfo;
	FC2::Error error;
	bool validSettings;
    bool supported;
    fmt7Info.mode = FC2::MODE_0;
    error = cam.GetFormat7Info(&fmt7Info, &supported);
	
	CameraSettings.mode = FC2::MODE_0;
	CameraSettings.offsetX = offsetX;
	CameraSettings.offsetY = offsetY;
	CameraSettings.width = width;
	CameraSettings.height = height;
	CameraSettings.pixelFormat = pixelFormat;
		
    // Validate the settings to make sure that they are valid
	error = cam.ValidateFormat7Settings(&CameraSettings, &validSettings, &PacketInfo);
    if (error != FC2::PGRERROR_OK)
    {
        return error;
    }

	if (!validSettings)
    {
        // Settings are not valid
		std::cout << "Format7 settings are not valid" << std::endl; 
		return error;
    }

    // Set the settings to the camera
	error = cam.SetFormat7Configuration(&CameraSettings, PacketInfo.recommendedBytesPerPacket);
    if (error != FC2::PGRERROR_OK)
    {
		return error;
    }	
	
	return error;

}	// end of config_imager_format

// ----------------------------------------------------------------------------------------

void config_property(FC2::Camera &cam, FC2::Property &prop, FC2::PropertyType type, bool AutoMode, bool OnOff, bool absControl)
{
	//Define the property to adjust.
	prop.type = type;

	// Configure auto adjust mode: True=>On, False=>Off 
	prop.autoManualMode = AutoMode;

	// Configure Property: True=>On, False=>Off
	prop.onOff = OnOff;

	//Ensure the property is set up to use absolute value control.
	prop.absControl = absControl;

	FC2::Error error = set_property(cam, prop);

}	// end of configProperty

// ----------------------------------------------------------------------------------------
//FC2::Error config_camera_propeties(FC2::Camera &cam, int32_t &sharpness, float &shutter, float &gain, float &brightness, float &auto_exp, float fps)
FC2::Error config_camera_propeties(FC2::Camera &cam, cam_properties_struct &cam_properties)
{
	FC2::Error error;

    FC2::Property Shutter, Gain, Sharpness, Framerate, Brightness, Auto_Exposure;

	// set the frame rate for the camera
	config_property(cam, Framerate, FC2::FRAME_RATE, false, true, true);
	error = set_abs_property(cam, Framerate, cam_properties.fps.value);
	if (error != FC2::PGRERROR_OK)
	{
		return error;
	}

	// config Sharpness to initial value and set to auto
	config_property(cam, Sharpness, FC2::SHARPNESS, false, true, false);
	error = set_int_property(cam, Sharpness, cam_properties.sharpness.value);
	if (error != FC2::PGRERROR_OK)
	{
		return error;
	}

	// configure the auto-exposure property
	config_property(cam, Auto_Exposure, FC2::AUTO_EXPOSURE, true, true, true);
	error = set_abs_property(cam, Auto_Exposure, cam_properties.auto_exp.value);
	if (error != FC2::PGRERROR_OK)
	{
		return error;
	}

	// configure the brightness property
	config_property(cam, Brightness, FC2::BRIGHTNESS, false, true, true);
	error = set_abs_property(cam, Brightness, cam_properties.brightness.value);
	if (error != FC2::PGRERROR_OK)
	{
		return error;
	}    

	// config Shutter to initial value and set to auto
	config_property(cam, Shutter, FC2::SHUTTER, false, true, true);
	error = set_abs_property(cam, Shutter, cam_properties.shutter.value);
	if (error != FC2::PGRERROR_OK)
	{
		return error;
	}

	//sleep_ms(500);

    // config Gain to initial value and set to auto
    //config_property(cam, Gain, FC2::GAIN, true, true, true);
    config_property(cam, Gain, FC2::GAIN, false, true, true);
    error = set_abs_property(cam, Gain, cam_properties.gain.value);
	if (error != FC2::PGRERROR_OK)
	{
		return error;
	}

	sleep_ms(1000); //2500

	// get the auto values
    cam_properties.shutter.value = get_abs_property(cam, Shutter);
    cam_properties.gain.value = get_abs_property(cam, Gain);
    cam_properties.sharpness.value = get_property(cam, Sharpness);
    cam_properties.auto_exp.value = get_abs_property(cam, Auto_Exposure);
    cam_properties.brightness.value = get_abs_property(cam, Brightness);

    //config_property(cam, Gain, FC2::GAIN, false, false, true);
    //error = set_abs_property(cam, Gain, cam_properties.gain);
    //if (error != FC2::PGRERROR_OK)
    //{
    //    return error;
    //}

	//sleep_ms(500);

    // reread the shutter properties
    //cam_properties.shutter = get_abs_property(cam, Shutter);

	// set the auto values to fixed
	//config_property(cam, Shutter, FC2::SHUTTER, false, false, true);
	//error = set_abs_property(cam, Shutter, cam_properties.shutter);
	// configProperty(cam, Gain, GAIN, false, false, true);
	// error = setProperty(cam, Gain, *gain);
	// configProperty(cam, Sharpness, SHARPNESS, false, false, false);
	// error = setProperty(cam, Sharpness, (float)*sharpness);
	// configProperty(cam, Auto_Exposure, AUTO_EXPOSURE, false, false, true);
	// error = setProperty(cam, Auto_Exposure, *auto_exp);

	return error;

}	// end ofconfigCameraPropeties

// ----------------------------------------------------------------------------------------


FC2::Error get_camera_selection(uint32_t &cam_index)
{
    uint32_t idx;
    uint32_t num_cameras;
    std::string console_input;
    std::vector<uint32_t> cam_sn;
    FC2::Error error;
    FC2::BusManager busMgr;
    
    // get the number of cameras attached
    error = busMgr.GetNumOfCameras(&num_cameras);
    if (error != FC2::PGRERROR_OK)
    {
        return error;
    }

    std::cout << "Number of cameras detected: " << num_cameras << std::endl;
    for (idx = 0; idx < num_cameras; ++idx)
    {
        cam_sn.push_back(0);
        error = busMgr.GetCameraSerialNumberFromIndex(idx, &cam_sn[idx]);
        std::cout << "Camera [" << idx << "] - Serial Number: " << cam_sn[idx] << std::endl;
    }

    std::cout << "Select Camera Index: ";
    std::getline(std::cin, console_input);
    cam_index = stoi(console_input);
    std::cout << std::endl;

    return error;

}   // end of get_camera_selection

// ----------------------------------------------------------------------------------------

FC2::Error init_camera(FC2::Camera &cam, uint32_t cam_index, FC2::FC2Config &camera_config, FC2::CameraInfo &cam_info)
{
    std::vector<uint32_t> cam_sn;
    FC2::Error error;
    FC2::BusManager busMgr;
    FC2::PGRGuid guid;

    // assume that we want to connect to the first camera and get the GUID for that camera
    error = busMgr.GetCameraFromIndex(cam_index, &guid);
    if (error != FC2::PGRERROR_OK)
    {
        return error;
    }

    // connect to the camera
    camera_connect(guid, cam);
    if (error != FC2::PGRERROR_OK)
    {
        return error;
    }

    // get the info from the camera
    error = cam.GetCameraInfo(&cam_info);
    if (error != FC2::PGRERROR_OK)
    {
        return error;
    }

    // Get the camera configuration
    error = cam.GetConfiguration(&camera_config);
    if (error != FC2::PGRERROR_OK)
    {
        return error;
    }

    camera_config.grabTimeout = 1000;// (unsigned int)(1000 / framerate);
    camera_config.highPerformanceRetrieveBuffer = true;
    camera_config.asyncBusSpeed = FC2::BUSSPEED_ANY;
    camera_config.numBuffers = 1;
    camera_config.grabMode = FC2::DROP_FRAMES;
    //camera_config.grabMode = FC2::BUFFER_FRAMES;

    // Set the camera configuration
    error = cam.SetConfiguration(&camera_config);
    if (error != FC2::PGRERROR_OK)
    {
        return error;
    }

    return error;

}   // end of init_camera

// ----------------------------------------------------------------------------------------

FC2::Error camera_power(FC2::Camera &cam, uint8_t state)
{
	FC2::Error error;
    uint32_t regVal = 0;
    uint32_t retries = 10;

    if (state == 0)
    {
        // turn camera off
        error = cam.WriteRegister(0x610, 0x00);
    }
    else
    {
        // turn camera on
        error = cam.WriteRegister(0x610, 0x80000000);
        if (error != FC2::PGRERROR_OK)
        {
            //PrintError(error);
            return error;
        }

        // Wait for camera to complete power-up
        do
        {
            sleep_ms(200);

            error = cam.ReadRegister(0x610, &regVal);
            if (error == FC2::PGRERROR_TIMEOUT)
            {
                // ignore timeout errors, camera may not be responding to
                // register reads during power-up
            }
            else if (error != FC2::PGRERROR_OK)
            {
                return error;
            }

            retries--;
        } while ((regVal & 0x80000000) == 0 && retries > 0);
    }

	return error;

}	// end of camera_power

// ----------------------------------------------------------------------------------------

FC2::Error set_software_trigger(FC2::Camera &cam, bool onOff)
{
	FC2::Error error;
    FC2::TriggerMode triggerMode;

	// Get current trigger settings
	error = cam.GetTriggerMode(&triggerMode);
	if (error != FC2::PGRERROR_OK)
	{
		return error;
	}

	// Set camera to trigger mode 0
	triggerMode.onOff = onOff;
	triggerMode.mode = 0;
	triggerMode.parameter = 0;
	triggerMode.source = 7;

	error = cam.SetTriggerMode(&triggerMode);
	if (error != FC2::PGRERROR_OK)
	{
		return error;
	}

	return error;
}	// SetSoftwareTrigger

// ----------------------------------------------------------------------------------------

bool poll_trigger_ready(FC2::Camera &cam)
{
	const uint32_t k_softwareTrigger = 0x62C;
	FC2::Error error;
    uint32_t regVal = 0;

	do
	{
		error = cam.ReadRegister(k_softwareTrigger, &regVal);
		if (error != FC2::PGRERROR_OK)
		{
            print_error(error);
			return false;
		}

	} while ((regVal >> 31) != 0);

	return true;
}	// end of PollForTriggerReady

// ----------------------------------------------------------------------------------------

FC2::Error fire_software_trigger(FC2::Camera &cam)
{
	const uint32_t k_softwareTrigger = 0x62C;
	const uint32_t k_fireVal = 0x80000000;

	return cam.WriteRegister(k_softwareTrigger, k_fireVal);

}	// end of FireSoftwareTrigger

// ----------------------------------------------------------------------------------------

void get_camera_temperature(FC2::Camera &cam, double &cam_temp)
{
    uint32_t regVal = 0;
    uint8_t temp[2] = { 0,0 };
    uint32_t t = 0;

    FC2::Property Temperture;

    // set the frame rate for the camera
    config_property(cam, Temperture, FC2::TEMPERATURE, true, true, true);

    cam_temp = 0.1*((double)get_property(cam, Temperture)) - 273.15;


    //// read the temperature register
    //error = cam.ReadRegister(TEMPERATURE, &regVal);

    //if ((regVal & 0x80000000) != 0)
    //{
    //    t = ((((regVal & 0x00FF) << 8) | ((regVal >> 8) & 0x00FF))>>4)&0x0FFF;
    //    //temp[0] = (regVal >> 8) & 0x00FF;
    //    //temp[1] = ((regVal & 0x00FF)<<8) |;
    //    cam_temp = 0.1*t;
    //}
    //else
    //    cam_temp = 0.0;

    //return error;

}	// end of get_camera_temperature
#endif

// ----------------------------------------------------------------------------------------

#endif  // CHAMELEON_UTILITIES_H

