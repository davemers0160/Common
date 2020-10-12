#ifndef _VINDEN_COMMANDS_H_
#define _VINDEN_COMMANDS_H_

#include <cstdint>

#include <wind_protocol.h>

//-----------------------------------------------------------------------------
enum command_id {
    
    ERROR_RESPONSE =    0x00,
    
    GET_CAMERA_VER =    0x01,
    
    END_CAMERA_CTRL =   0x02,
    
    LENS_VERSION =      0x41,
    LENS_READY =        0x42,
    
    SET_ZOOM_INDEX =    0x45,
    GET_ZOOM_INDEX =    0x46,
    
    GET_ZOOM_MTR_POS =  0x47,
    
    SET_FOCUS_POS =     0x48,
    GET_FOCUS_POS =     0x49,
    SET_INF_FOCUS =     0x4A,
    
    START_AUTOFOCUS =   0x4C,
    STOP_AUTOFOCUS =    0x4D,
    
    SET_ZOOM_SPEED =    0x4E,
    GET_ZOOM_SPEED =    0x4F,
    
    SET_FOCUS_SPEED =   0x50,
    GET_FOCUS_SPEED =   0x51,
    
    SENSOR_VERSION =    0x81,
    
    FLAT_FIELD_CORR =   0x82,
    
    SET_AUTO_FFC_PER =  0x85,
    GET_AUOT_FFC_PER =  0x86,
    
    SET_AUTO_FFC_MODE = 0x87,
    GET_AUTO_FFC_MODE = 0x88,
    
    SET_SHUTTER =       0x89,
    
    GET_SENSOR_READY =  0x8A,
       
};

//-----------------------------------------------------------------------------
std::vector<std::string> vinden_error_code = {
    "None",
    "Wrong command ID",
    "Wrond data size",
    "Argument out of range",
    "Wrong checksum",
    "Receive buffer full",
    "Communication timeout",
    "Boot up error",
    "Error while writing",
    "Error while reading",
    "Lens serial 1 commincation issue",
    "Sensor serial 2 commincation issue",
    "Command not implemented",
    "Telemtry error",
    "Undefined camera model",
    "Autofocus running"
};

//-----------------------------------------------------------------------------
class lens{
    
    uint16_t fw_maj_rev;
    uint16_t fw_min_rev;
    uint16_t sw_maj_rev;
    uint16_t sw_min_rev;
    
    uint16_t zoom_index;
    uint16_t zoom_position;
    uint8_t zoom_speed;
    
    uint16_t focus_position;
    uint8_t focus_speed;
    
    //-----------------------------------------------------------------------------
    lens() = default;
    
    lens(uint16_t fw_maj, uint16_t fw_min, uint16_t sw_maj, uint16_t fw_min)
    {
        fw_maj_rev = fw_maj;
        fw_min_rev = fw_min;
        sw_maj_rev = sw_maj;
        sw_min_rev = sw_min;
    }        
    
    //-----------------------------------------------------------------------------
    uint8_t get_version(void)
    {
        uint8_t error = 0;
        wind_protocol lens_packet(LENS_VERSION);
        
        // build a fip packet
        fip_protocol fip_packet(0x3D, lens_packet.to_array());
        
        // send fip packet to the camera controller
        
        
        // get the response from the camera in the form of a fip packet
        
        
        // check the error
        
        
        
        return error;
    }
    
    //-----------------------------------------------------------------------------
    uint8_t lens_ready(uint8_t &ready)
    {
        uint8_t error = 0;
        wind_protocol lens_packet(LENS_READY);

        // build a fip packet
        fip_protocol fip_packet(0x3D, lens_packet.to_array());        
        
        // send fip packet to the camera controller
        
        
        // get the response from the camera in the form of a fip packet
        
        
        // check the error

        return error;
    }

    //-----------------------------------------------------------------------------
    uint8_t set_zoom_index(uint16_t zi)
    {
        uint8_t error = 0;
        wind_protocol lens_packet(SET_ZOOM_INDEX);
        lens_packet.update_payload(zi);

        // build a fip packet
        fip_protocol fip_packet(0x3D, lens_packet.to_array());        
        
        // send fip packet to the camera controller
        
        
        // get the response from the camera in the form of a fip packet
        
        
        // check the error

        return error;
    }

    //-----------------------------------------------------------------------------
    uint8_t get_zoom_index(uint16_t &zi)
    {
        uint8_t error = 0;
        wind_protocol lens_packet(GET_ZOOM_INDEX);

        // build a fip packet
        fip_protocol fip_packet(0x3D, lens_packet.to_array());        
        
        // send fip packet to the camera controller
        
        
        // get the response from the camera in the form of a fip packet
        
        
        // check the error

        return error;
    }

    //-----------------------------------------------------------------------------
    uint8_t get_zoom_index(uint16_t &zi)
    {
        uint8_t error = 0;
        wind_protocol lens_packet(GET_ZOOM_INDEX);

        // build a fip packet
        fip_protocol fip_packet(0x3D, lens_packet.to_array());        
        
        // send fip packet to the camera controller
        
        
        // get the response from the camera in the form of a fip packet
        
        
        // check the error

        return error;
    }
    
    //-----------------------------------------------------------------------------
    inline friend std::ostream& operator<< (
        std::ostream& out,
        const vinden_lens& item
    )
    {
        out << "  Firmware Version: " << (uint32_t)item.fw_maj_rev << "." << item.fw_min_rev << std::endl;
        out << "  Software Version: " << (uint32_t)item.sw_maj_rev << "." << item.sw_min_rev << std::endl;
        return out;
    }
};


//-----------------------------------------------------------------------------
class sensor{
    
    uint16_t fw_maj_rev;
    uint16_t fw_min_rev;
    uint16_t sw_maj_rev;
    uint16_t sw_min_rev;
    
    uint16_t ffc_period;
    uint8_t ffc_mode;
    
    
    sensor() = default;
    
    sensor(uint16_t fw_maj, uint16_t fw_min, uint16_t sw_maj, uint16_t fw_min)
    {
        fw_maj_rev = fw_maj;
        fw_min_rev = fw_min;
        sw_maj_rev = sw_maj;
        sw_min_rev = sw_min;
    }        
    
    
    inline friend std::ostream& operator<< (
        std::ostream& out,
        const sensor& item
    )
    {
        out << "  Firmware Version: " << (uint32_t)item.fw_maj_rev << "." << item.fw_min_rev << std::endl;
        out << "  Software Version: " << (uint32_t)item.sw_maj_rev << "." << item.sw_min_rev << std::endl;
        return out;
    }
};

//-----------------------------------------------------------------------------



#endif  // _VINDEN_COMMANDS_H_
