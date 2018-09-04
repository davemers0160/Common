#ifndef _FTDI_FUNCTIONS_H
#define _FTDI_FUNCTIONS_H

#include <cstdint>
#include <string>
#include <iostream>
#include <iomanip>
#include <vector>

#include "ftd2xx.h"

struct ftdiDeviceDetails //structure storage for FTDI device details
{
    int32_t device_number;
    uint32_t type;
    uint32_t baud_rate;
    std::string description;
    std::string serial_number;
};



uint32_t get_device_list(std::vector<ftdiDeviceDetails> &device)
{
    FT_HANDLE ftHandleTemp; 
    FT_DEVICE_LIST_INFO_NODE dev_info[32];
    uint32_t dev_number = 0, dev_found = 0;
    unsigned long num_devices = 0;
    unsigned long flags, id, type, loc_id;
    char serial_number[16];
    char description[64];
    ftdiDeviceDetails tmp_dev;
    // search for devices connected to the USB port
    FT_CreateDeviceInfoList(&num_devices);

    device.clear();

    if (num_devices > 0)
    {
        if (FT_GetDeviceInfoList(dev_info, &num_devices) == FT_OK)
        {

            for(uint32_t idx=0; idx<num_devices; ++idx)
            {
                if (FT_GetDeviceInfoDetail(idx, &flags, &type, &id, &loc_id, serial_number, description, &ftHandleTemp) == FT_OK)
                {
                    tmp_dev.device_number = idx;
                    tmp_dev.type = type;
                    tmp_dev.description = (std::string)description;
                    tmp_dev.serial_number = (std::string)serial_number;

                    device.push_back(tmp_dev);
                }

            }
        }
    }

    return num_devices;

}   // end of get_device_list


// ----------------------------------------------------------------------------------------

//FT_HANDLE OpenComPort(ftdiDeviceDetails &device, std::string descript)
FT_HANDLE open_com_port(ftdiDeviceDetails &device)
{
    FT_HANDLE ftHandle = NULL;
    long lComPortNumber;

    //if (FT_OpenEx((void *)device.serial_number.c_str(), FT_OPEN_BY_SERIAL_NUMBER, &ftHandle) == FT_OK)
    if (FT_Open(device.device_number, &ftHandle) == FT_OK)
    {

        if (FT_SetBaudRate(ftHandle, device.baud_rate) != FT_OK)
        {
            std::cout << "Error setting baud rate!" << std::endl;
            return ftHandle;
        }
            //			if (FT_SetBaudRate(ftHandle, 230400l) != FT_OK)
            //printf("ERROR: Baud rate not supported\n");

        FT_SetDataCharacteristics(ftHandle, FT_BITS_8, FT_STOP_BITS_2, FT_PARITY_NONE);
        FT_SetTimeouts(ftHandle, 5000, 100);
        if (FT_GetComPortNumber(ftHandle, &lComPortNumber) == FT_OK)
        {
            if (lComPortNumber == -1) // No COM port assigned }
                std::cout << "The device selected does not have a Comm Port assigned!" << std::endl << std::endl;
            else
                std::cout << "FTDI device " << device.description << " found on COM:" << std::setw(2) << std::setfill('0') << lComPortNumber << std::endl << std::endl;
        }
    }

    return ftHandle;
}	// end of OpenComPort


FT_STATUS close_com_port(FT_HANDLE ftHandle)
{
    FT_STATUS status = FT_Close(ftHandle);
    return status;
}

// ----------------------------------------------------------------------------------------
inline std::ostream& operator<< (
    std::ostream& out,
    const ftdiDeviceDetails& item
    )
{
    using std::endl;
    out << "FTDI Device [" << item.device_number <<  "]: ";
    out << item.description;
    out << " (" << item.serial_number << ")";
    //out << " Baud Rate: " << item.baud_rate;
    out << std::endl;
    return out;
}

// ----------------------------------------------------------------------------------------	

#endif  // _FTDI_FUNCTIONS_H

