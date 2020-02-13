#ifndef _SPINNAKER_UTILITIES_H
#define _SPINNAKER_UTILITIES_H

#include "Spinnaker.h"
#include "SpinGenApi/SpinnakerGenApi.h"
#include <cstdint>
#include <iostream>
#include <iomanip>
#include <string>

#include "sleep_ms.h"

enum trigger_type
{
    SOFTWARE = 0,
    HARDWARE = 1
};

const std::vector<Spinnaker::GenICam::gcstring> trigger_name = {"Software", "Line0"};


// ----------------------------------------------------------------------------------------
inline std::ostream& operator<< (std::ostream& out, const Spinnaker::LibraryVersion& item)
{
    // Print out current library version
    out << "Spinnaker library version: " << item.major << "." << item.minor << "." << item.type << "." << item.build << std::endl;
    return out;
}

// ----------------------------------------------------------------------------------------
inline std::ostream& operator<< (std::ostream& out, const Spinnaker::GenApi::FeatureList_t& item)
{
    out << "Camera Information: " << std::endl;
    out << "  Serial Number:     " << (*(item.begin() + 1))->ToString() << std::endl;
    out << "  Camera Model:      " << (*(item.begin() + 3))->ToString() << std::endl;
    out << "  Camera Vendor:     " << (*(item.begin() + 2))->ToString() << std::endl;
    out << "  Firmware version:  " << (*(item.begin() + 7))->ToString() << std::endl;

    return out;
}

// ----------------------------------------------------------------------------------------
inline std::ostream& operator<< (std::ostream& out, const Spinnaker::CameraPtr& item)
{
    Spinnaker::GenApi::CStringPtr sn = item->GetTLDeviceNodeMap().GetNode("DeviceSerialNumber");
    Spinnaker::GenApi::CStringPtr model = item->GetTLDeviceNodeMap().GetNode("DeviceModelName");
    Spinnaker::GenApi::CStringPtr vn = item->GetTLDeviceNodeMap().GetNode("DeviceVendorName");
    Spinnaker::GenApi::CStringPtr fw = item->GetTLDeviceNodeMap().GetNode("DeviceVersion");

    out << "Camera Information: " << std::endl;
    out << "  Serial Number:     " << sn->ToString() << std::endl;
    out << "  Camera Model:      " << model->ToString() << std::endl;
    out << "  Camera Vendor:     " << vn->ToString() << std::endl;
    out << "  Firmware version:  " << fw->ToString() << std::endl;

    return out;
}


// ----------------------------------------------------------------------------------------
void print_device_info(std::ostream& out, Spinnaker::GenApi::INodeMap& node_map)
{
    Spinnaker::GenApi::FeatureList_t features;
    Spinnaker::GenApi::CCategoryPtr category = node_map.GetNode("DeviceInformation");
    if (Spinnaker::GenApi::IsAvailable(category) && Spinnaker::GenApi::IsReadable(category))
    {
        category->GetFeatures(features);
        out << features;
    }
    else
    {
        out << "Device control information not available." << std::endl;
    }
    out << std::endl;

}

// ----------------------------------------------------------------------------------------
uint32_t get_camera_selection(Spinnaker::CameraList& cam_list, uint32_t& cam_index, std::vector<std::string> &cam_sn)
{
    uint32_t idx;
    std::string console_input;
    cam_sn.clear();

    uint32_t num_cams = cam_list.GetSize();
    std::cout << "Number of cameras detected: " << num_cams << std::endl;

    for (idx = 0; idx < num_cams; ++idx)
    {
        Spinnaker::CameraPtr cam = cam_list.GetByIndex(idx);
        Spinnaker::GenApi::CStringPtr sn = cam->GetTLDeviceNodeMap().GetNode("DeviceSerialNumber");
        Spinnaker::GenApi::CStringPtr model = cam->GetTLDeviceNodeMap().GetNode("DeviceModelName");
        cam_sn.push_back(std::string(sn->ToString()));
        std::cout << "[" << idx << "] " << model->ToString() << " - Serial Number: " << cam_sn[idx] << std::endl;
    }

    if (num_cams > 0)
    {
        std::cout << "Select Camera Index: ";
        std::getline(std::cin, console_input);
        try {
            cam_index = std::stoi(console_input);
        }
        catch (...)
        {
            std::cout << "Error reading in camera index!" << std::endl;
            exit(0);
        }
        std::cout << std::endl;
    }

    return num_cams;
}

// ----------------------------------------------------------------------------------------
void query_interfaces(Spinnaker::InterfacePtr pi)
{
    try {

        //Spinnaker::GenApi::INodeMap& node_map_interface = pi->GetTLNodeMap();

        pi->UpdateCameras();

        Spinnaker::CameraList camera_list = pi->GetCameras();

        // Retrieve number of cameras
        uint32_t num_cams = camera_list.GetSize();
        // Return if no cameras detected
        if (num_cams == 0)
        {
            std::cout << "No devices detected." << std::endl;
            return;
        }

        // Print device vendor and model name for each camera on the interface
        for (uint32_t idx = 0; idx < num_cams; ++idx)
        {
            //
            // Select camera
            //
            // *** NOTES ***
            // Each camera is retrieved from a camera list with an index. If
            // the index is out of range, an exception is thrown.
            //
            Spinnaker::CameraPtr p_cam = camera_list.GetByIndex(idx);

            // Retrieve TL device nodemap; please see NodeMapInfo example for
            // additional comments on transport layer nodemaps
            Spinnaker::GenApi::INodeMap& node_map_TL_device = p_cam->GetTLDeviceNodeMap();

            std::cout << "Device " << idx << " ";

            // Print device vendor name and device model name
            //
            // *** NOTES ***
            // Grabbing node information requires first retrieving the node and
            // then retrieving its information. There are two things to keep in
            // mind. First, a node is distinguished by type, which is related
            // to its value's data type. Second, nodes should be checked for
            // availability and readability/writability prior to making an
            // attempt to read from or write to the node.
            //
            Spinnaker::GenApi::CStringPtr vendor_name = node_map_TL_device.GetNode("DeviceVendorName");
            if (IsAvailable(vendor_name) && IsReadable(vendor_name))
            {
                //gcstring deviceVendorName = vendor_name->ToString();

                std::cout << vendor_name->ToString() << " ";
            }

            Spinnaker::GenApi::CStringPtr model_name = node_map_TL_device.GetNode("DeviceModelName");
            if (IsAvailable(model_name) && IsReadable(model_name))
            {
                //gcstring deviceModelName = model_name->ToString();

                std::cout << model_name->ToString() << std::endl;
            }
        }

        camera_list.Clear();


    }
    catch (Spinnaker::Exception & e)
    {
        std::cout << e.what() << std::endl;
    }
}

// ----------------------------------------------------------------------------------------
int configure_trigger(Spinnaker::GenApi::INodeMap& node_map, const trigger_type source, bool on_off)
{
    int result = 0;

    try
    {
        //
        // Ensure trigger mode off
        //
        // *** NOTES ***
        // The trigger must be disabled in order to configure whether the source
        // is software or hardware.
        //
        Spinnaker::GenApi::CEnumerationPtr trigger_mode = node_map.GetNode("TriggerMode");
        if (!Spinnaker::GenApi::IsAvailable(trigger_mode) || !Spinnaker::GenApi::IsReadable(trigger_mode))
        {
            std::cout << "Unable to disable trigger mode (node retrieval). Aborting..." << std::endl;
            return -1;
        }

        Spinnaker::GenApi::CEnumEntryPtr trigger_status = trigger_mode->GetEntryByName("Off");
        if (!Spinnaker::GenApi::IsAvailable(trigger_status) || !Spinnaker::GenApi::IsReadable(trigger_status))
        {
            std::cout << "Unable to disable trigger mode (enum entry retrieval). Aborting..." << std::endl;
            return -1;
        }
        trigger_mode->SetIntValue(trigger_status->GetValue());
        //std::cout << "Trigger mode disabled..." << std::endl;

        //
        // Select trigger source
        //
        // *** NOTES ***
        // The trigger source must be set to hardware or software while trigger
        // mode is off.
        //
        Spinnaker::GenApi::CEnumerationPtr trigger_source = node_map.GetNode("TriggerSource");
        if (!Spinnaker::GenApi::IsAvailable(trigger_source) || !Spinnaker::GenApi::IsWritable(trigger_source))
        {
            std::cout << "Unable to set trigger mode (node retrieval). Aborting..." << std::endl;
            return -1;
        }

        //if (source == SOFTWARE)
        //{
        //    // Set trigger mode to software
        //    Spinnaker::GenApi::CEnumEntryPtr trigger_source_soft = trigger_source->GetEntryByName("Software");
        //    if (!Spinnaker::GenApi::IsAvailable(trigger_source_soft) || !Spinnaker::GenApi::IsReadable(trigger_source_soft))
        //    {
        //        std::cout << "Unable to set trigger mode (enum entry retrieval). Aborting..." << std::endl;
        //        return -1;
        //    }
        //    trigger_source->SetIntValue(trigger_source_soft->GetValue());
        //    //std::cout << "Trigger source set to software..." << std::endl;
        //}
        //else if (source == HARDWARE)
        //{
        //    // Set trigger mode to hardware ('Line0')
        //    Spinnaker::GenApi::CEnumEntryPtr trigger_source_hard = trigger_source->GetEntryByName("Line0");
        //    if (!Spinnaker::GenApi::IsAvailable(trigger_source_hard) || !Spinnaker::GenApi::IsReadable(trigger_source_hard))
        //    {
        //        std::cout << "Unable to set trigger mode (enum entry retrieval). Aborting..." << std::endl;
        //        return -1;
        //    }
        //    trigger_source->SetIntValue(trigger_source_hard->GetValue());
        //    //std::cout << "Trigger source set to hardware..." << std::endl;
        //}

        Spinnaker::GenApi::CEnumEntryPtr ts = trigger_source->GetEntryByName(trigger_name[source]);
        if (!Spinnaker::GenApi::IsAvailable(ts) || !Spinnaker::GenApi::IsReadable(ts))
        {
            std::cout << "Unable to set trigger mode (enum entry retrieval). Aborting..." << std::endl;
            return -1;
        }
        trigger_source->SetIntValue(ts->GetValue());
        std::cout << "Trigger source set to " << trigger_name[source] << std::endl;

        //
        // Turn trigger mode on
        //
        // *** LATER ***
        // Once the appropriate trigger source has been set, turn trigger mode
        // on in order to retrieve images using the trigger.
        //
        if (on_off)
        {
            //Spinnaker::GenApi::CEnumEntryPtr ptrTriggerModeOn = ptrTriggerMode->GetEntryByName("On");
            trigger_status = trigger_mode->GetEntryByName("On");
            if (!Spinnaker::GenApi::IsAvailable(trigger_status) || !Spinnaker::GenApi::IsReadable(trigger_status))
            {
                std::cout << "Unable to enable trigger mode (enum entry retrieval). Aborting..." << std::endl;
                return -1;
            }
            trigger_mode->SetIntValue(trigger_status->GetValue());

            sleep_ms(1000);         // Blackfly and Flea3 GEV cameras need 1 second delay after trigger mode is turned on
            std::cout << "Trigger mode turned back on..." << std::endl << std::endl;
        }
    }
    catch (Spinnaker::Exception & e)
    {
        std::cout << "Error: " << e.what() << std::endl;
        result = -1;
    }
    return result;

}   // end of configure_trigger


// ----------------------------------------------------------------------------------------
int fire_software_trigger(Spinnaker::GenApi::INodeMap& node_map)
{
    int result = 0;
    try
    {
        //
        // Use trigger to capture image
        //
        // *** NOTES ***
        // The software trigger only feigns being executed by the Enter key;
        // what might not be immediately apparent is that there is not a
        // continuous stream of images being captured; in other examples that
        // acquire images, the camera captures a continuous stream of images.
        // When an image is retrieved, it is plucked from the stream.

        // Execute software trigger
        Spinnaker::GenApi::CCommandPtr trigger_command = node_map.GetNode("TriggerSoftware");
        if (!Spinnaker::GenApi::IsAvailable(trigger_command) || !Spinnaker::GenApi::IsWritable(trigger_command))
        {
            std::cout << "Unable to execute trigger. Aborting..." << std::endl;
            return -1;
        }
        trigger_command->Execute();
        sleep_ms(2000);         // Blackfly and Flea3 GEV cameras need 2 second delay after software trigger

    }
    catch (Spinnaker::Exception & e)
    {
        std::cout << "Error: " << e.what() << std::endl;
        result = -1;
    }
    return result;


}	// end of fire_software_trigger

#endif  // _SPINNAKER_UTILITIES_H
