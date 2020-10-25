#ifndef _SO_CAM_COMMANDS_H_
#define _SO_CAM_COMMANDS_H_

#include <cstdint>

#include <wind_protocol.h>
#include <fip_protocol.h>

//-----------------------------------------------------------------------------
enum system_command {
    ERROR_RESPONSE =    0x00,
    
    GET_CAMERA_VER =    0x01,
    
    END_CAMERA_CTRL =   0x02,    
};

enum lens_command {
    
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
    
    RUN_CONT_ZOOM =     0x52,
    RUN_CONT_FOCUS =    0x53,
    
    SET_LENS_BLUR =     0x54
};

enum sensor_command {
    SENSOR_VERSION =    0x81,
    
    FLAT_FIELD_CORR =   0x82,
    
    LOAD_NUC_TABLE =    0x83,
    GET_NUC_TABLE =     0x84,
    
    SET_AUTO_FFC_PER =  0x85,
    GET_AUOT_FFC_PER =  0x86,
    
    SET_AUTO_FFC_MODE = 0x87,
    GET_AUTO_FFC_MODE = 0x88,
    
    SET_SHUTTER =       0x89,
    
    GET_SENSOR_READY =  0x8A,
};

//-----------------------------------------------------------------------------
std::vector<std::string> error_codes = {
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
/** @brief Sierra Olympic Lens Class

This class build the packets in the to communicate with the camera lens.
*/
class lens_class{

public:
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
    lens_class() = default;
    
    lens_class(uint16_t fw_maj, uint16_t fw_min, uint16_t sw_maj, uint16_t sw_min) : fw_maj_rev(fw_maj), fw_min_rev(fw_min), sw_maj_rev(sw_maj), sw_min_rev(sw_min)
    {
        zoom_index = 0;
        zoom_position = 0;
        zoom_speed = 0;
        
        focus_position = 0;
        focus_speed = 0;
    }        
    
    lens_class(std::vector<uint8_t> data)
    {
        fw_maj_rev = data[1]<<8 | data[0];
        fw_min_rev = data[3]<<8 | data[2];
        sw_maj_rev = data[5]<<8 | data[4];
        sw_min_rev = data[7]<<8 | data[6];
        
        zoom_index = 0;
        zoom_position = 0;
        zoom_speed = 0;
        
        focus_position = 0;
        focus_speed = 0;        
    }
    
    //-----------------------------------------------------------------------------
    /**
    @brief Get the lens version.

    This function builds a fip protocol packet to retrieve the camera lens version.
    
    @param[out] fip_protocol that contains the structure to retrieve the lens version.

    @note The returned data will contain the FW Major Revision, FW Minor Revision, SW Major Version, SW Minor Version.

    @sa fip_protocol, wind_protocol
    */
    fip_protocol get_version(void)
    {
        wind_protocol lens_packet(LENS_VERSION);
        
        // build a fip packet
        return fip_protocol(0x3D, lens_packet.to_array());
    }
    
    //-----------------------------------------------------------------------------
    /**
    @brief Get lens ready.

    This function builds a fip protocol packet to determine if the camera lens is ready.

    @param[out] fip_protocol that contains the structure to retrieve the lens status.

    @note The returned status will be 0 when the lens is busy and unable to accept new commands, and while autofocus is running.  Otherwise the statua will be set to 1.

    @sa fip_protocol, wind_protocol
    */
    fip_protocol ready(void)
    {
        wind_protocol lens_packet(LENS_READY);

        // build a fip packet
        return fip_protocol(0x3D, lens_packet.to_array());
    }

    //-----------------------------------------------------------------------------
    /**
    @brief Set zoom index.

    This function builds a fip protocol packet to set the camera to go to the specified zoom index.

    @param[in] Zoom Index : (0-Max Zoom Index)
    @param[out] fip_protocol that contains the structure to set the zoom index.

    @note The command will return immediately, even while the lens is moving to the sent index.
    Focal Length    Max Zoom Index
      - 15-75           17
      - 25-150          26
      - 40-300          18

    @sa fip_protocol, wind_protocol
    */
    fip_protocol set_zoom_index(uint16_t value)
    {
        wind_protocol lens_packet(SET_ZOOM_INDEX);
        lens_packet.update_payload(value);

        // build a fip packet
        return fip_protocol(0x3D, lens_packet.to_array());
    }

    //-----------------------------------------------------------------------------
    /**
    @brief Get zoom index.

    This function builds a fip protocol packet to get the zoom motor position that the lens is currently poisitioned at.  

    @param[out] fip_protocol that contains the structure to get the zoom index.

    @note The returned packet will contain the zoom index of the camera lens.

    @sa fip_protocol, wind_protocol
    */
    fip_protocol get_zoom_index(void)
    {
        wind_protocol lens_packet(GET_ZOOM_INDEX);

        // build a fip packet
        return fip_protocol(0x3D, lens_packet.to_array());
    }

    //-----------------------------------------------------------------------------
    /**
    @brief Get zoom position.

    This function builds a fip protocol packet to get the zoom motor position that the lens is currently poisitioned at.

    @param[out] fip_protocol that contains the structure to get the zoom position.

    @note The returned packet will contain the zoom position of the camera lens.

    @sa fip_protocol, wind_protocol
    */
    fip_protocol get_zoom_position(void)
    {
        wind_protocol lens_packet(GET_ZOOM_MTR_POS);

        // build a fip packet
        return fip_protocol(0x3D, lens_packet.to_array());
    }
    
    //-----------------------------------------------------------------------------
    /**
    @brief Set focus position.

    This function builds a fip protocol packet to set the camera to the specified motor position. The command will return immediately, even while the lens is moving to the send position.

    @param[in] value Position : (0-65534)
    @param[out] fip_protocol that contains the structure to set the focus position.

    @sa fip_protocol, wind_protocol
    */
    fip_protocol set_focus_position(uint16_t value)
    {
        wind_protocol lens_packet(SET_FOCUS_POS);
        lens_packet.update_payload(value);

        // build a fip packet
        return fip_protocol(0x3D, lens_packet.to_array());
    }

    //-----------------------------------------------------------------------------
    /**
    @brief Get focus position.

    This function builds a fip protocol packet to get the focus position of the camera lens.

    @param[out] fip_protocol that contains the structure to get the focus position.

    @note The returned packet will contain the focus position of the camera lens.

    @sa fip_protocol, wind_protocol
    */
    fip_protocol get_focus_position(void)
    {
        wind_protocol lens_packet(GET_FOCUS_POS);

        // build a fip packet
        return fip_protocol(0x3D, lens_packet.to_array());
    }

    //-----------------------------------------------------------------------------
    /**
    @brief Set infinity focus.

    This function builds a fip protocol packet to set the focus motor to the len's calibrated infinity focus position, which corresponds to the focus position 32767.

    @param[out] fip_protocol that contains the structure to set the lens to the infinity focus.

    @sa fip_protocol, wind_protocol
    */
    fip_protocol set_infinity_focus(void)
    {
        wind_protocol lens_packet(SET_INF_FOCUS);

        // build a fip packet
        return fip_protocol(0x3D, lens_packet.to_array());
    }

    //-----------------------------------------------------------------------------
    /**
    @brief Start autofocus.

    This function builds a fip protocol packet to start the camera autofocus.

      - In non-blocking mode, the command will return a response before autofocus has completed. The autofocus can be queried on whether it is still running with the "Get Lens Ready" command and can be stopped with the "Abort Autofocus" command; all other commands will return an error. 
      
      - In blocking mode the Autofocus command to only return once autofocus is complete.

    @param[in] value 0 - Non Blocking, 1 - Blocking
    @param[out] fip_protocol that contains the structure to start the autofocus.

    @sa fip_protocol, wind_protocol
    */
    fip_protocol start_autofocus(uint8_t value)
    {
        wind_protocol lens_packet(START_AUTOFOCUS);
        lens_packet.update_payload(value);

        // build a fip packet
        return fip_protocol(0x3D, lens_packet.to_array());
    }

    //-----------------------------------------------------------------------------
    /**
    @brief Stop autofocus.

    This function builds a fip protocol packet to stop the camera autofocus.  Returns when autofocus is successfully aborted.

    @param[out] fip_protocol that contains the structure to stop the autofocus.

    @sa fip_protocol, wind_protocol
    */
    fip_protocol stop_autofocus(void)
    {
        wind_protocol lens_packet(STOP_AUTOFOCUS);

        // build a fip packet
        return fip_protocol(0x3D, lens_packet.to_array());
    }

    //-----------------------------------------------------------------------------
    /**
    @brief Set zoom speed.

    This function builds a fip protocol packet to set the lens zoom speed.

    @param[in] value Speed : 0 is the default manufacturer speed of the lens. 1 is the slowest speed the lens will zoom at, and 100 is the fastest.
    @param[out] fip_protocol that contains the structure to set the zoom speed.

    @sa fip_protocol, wind_protocol
    */
    fip_protocol set_zoom_speed(uint8_t value)
    {
        wind_protocol lens_packet(GET_ZOOM_INDEX);
        lens_packet.update_payload(value);

        // build a fip packet
        return fip_protocol(0x3D, lens_packet.to_array());
    }

    //-----------------------------------------------------------------------------
    /**
    @brief Get zoom speed.

    This function builds a fip protocol packet to get the lens zoom speed.

    @param[out] fip_protocol that contains the structure to set the focus position.

    @sa fip_protocol, wind_protocol
    */
    fip_protocol get_zoom_speed(void)
    {
        wind_protocol lens_packet(GET_ZOOM_INDEX);

        // build a fip packet
        return fip_protocol(0x3D, lens_packet.to_array());
    }

    //-----------------------------------------------------------------------------
    /**
    @brief Set focus speed.

    This function builds a fip protocol packet to set the lens focus speed.  This speed will effect the speed and performance of autofocus.

    @param[in] value Speed : 0 is the default manufacturer speed of the lens. 1 is the slowest speed the lens will zoom at, and 100 is the fastest.
    @param[out] fip_protocol that contains the structure to set the focus speed.

    @sa fip_protocol, wind_protocol
    */
    fip_protocol set_focus_speed(uint8_t value)
    {
        wind_protocol lens_packet(GET_ZOOM_INDEX);
        lens_packet.update_payload(value);

        // build a fip packet
        return fip_protocol(0x3D, lens_packet.to_array());
    }

    //-----------------------------------------------------------------------------
    /**
    @brief Get focus speed.

    This function builds a fip protocol packet to Get the lens focus speed. 

    @param[out] fip_protocol that contains the structure to get the focus speed.

    @sa fip_protocol, wind_protocol
    */
    fip_protocol get_focus_speed(void)
    {
        wind_protocol lens_packet(GET_ZOOM_INDEX);

        // build a fip packet
        return fip_protocol(0x3D, lens_packet.to_array());
    }

    //-----------------------------------------------------------------------------
    /**
    @brief Run continuous zoom.

    This function builds a fip protocol packet to start zooming in either the narrow or wide direction at the set zoom speed, or stops a zoom in progress.
    
    The zoom may stop at a position that is not directly related to a zoom index position, in this case the zoom index will return the closest zoom index in the wide direction.

    @param[in] value Mode : 0 - Stop, 1 - Zoom Narrow, 2- Zoom Wide
    @param[out] fip_protocol that contains the structure to set the zoom mode.

    @sa fip_protocol, wind_protocol
    */
    fip_protocol run_continuous_zoom(uint8_t value)
    {
        wind_protocol lens_packet(RUN_CONT_ZOOM);
        lens_packet.update_payload(value);

        // build a fip packet
        return fip_protocol(0x3D, lens_packet.to_array());
    }

    //-----------------------------------------------------------------------------
    /**
    @brief Run continuous focus.

    This function builds a fip protocol packet to start focusing in either the the far or near direction at the set focus speed, or stops a focus in progress.

    @param[in] value Mode : 0 - Stop, 1 - Focus Far, 2- Focus Near
    @param[out] fip_protocol that contains the structure to set the focus mode.

    @sa fip_protocol, wind_protocol
    */
    fip_protocol run_continuous_focus(uint8_t value)
    {
        wind_protocol lens_packet(RUN_CONT_FOCUS);
        lens_packet.update_payload(value);

        // build a fip packet
        return fip_protocol(0x3D, lens_packet.to_array());
    }

    //-----------------------------------------------------------------------------
    /**
    @brief Set lens blur.

    This function builds a fip protocol packet to blur the lens so a flat field correction can be performed. A lens blur is automatically performed when the flat field correction command is issued and blur lens is set to 1.

    @param[in] value Mode : 0 - Unblur lens, 1 - Blur lens
    @param[out] fip_protocol that contains the structure to set the blur mode.

    @sa fip_protocol, wind_protocol
    */
    fip_protocol set_lens_blur(uint8_t value)
    {
        wind_protocol lens_packet(SET_LENS_BLUR);
        lens_packet.update_payload(value);

        // build a fip packet
        return fip_protocol(0x3D, lens_packet.to_array());
    }
    
    //-----------------------------------------------------------------------------
    inline friend std::ostream& operator<< (
        std::ostream& out,
        const lens_class& item
    )
    {
        out << "  Firmware Version: " << (uint32_t)item.fw_maj_rev << "." << (uint32_t)item.fw_min_rev << std::endl;
        out << "  Software Version: " << (uint32_t)item.sw_maj_rev << "." << (uint32_t)item.sw_min_rev << std::endl;
        out << "  Zoom Index:       " << (uint32_t)item.zoom_index << std::endl;
        out << "  Zoom Position:    " << (uint32_t)item.zoom_position << std::endl;
        out << "  Zoom Speed:       " << (uint32_t)item.zoom_speed << std::endl;
        out << "  Focus Position:   " << (uint32_t)item.focus_position << std::endl;
        out << "  Focus Speed:      " << (uint32_t)item.focus_speed << std::endl;
        return out;
    }

private:

};  // end lens_class


//-----------------------------------------------------------------------------
/** @brief Sierra Olympic Sensor Class

This class build the packets in the to communicate with the camera sensor.
*/
class sensor_class{
    
public:
    uint16_t fw_maj_rev;
    uint16_t fw_min_rev;
    uint16_t sw_maj_rev;
    uint16_t sw_min_rev;
    
    uint16_t ffc_period;
    uint8_t ffc_mode;
    
    
    sensor_class() = default;
    
    sensor_class(uint16_t fw_maj, uint16_t fw_min, uint16_t sw_maj, uint16_t sw_min) : fw_maj_rev(fw_maj), fw_min_rev(fw_min), sw_maj_rev(sw_maj), sw_min_rev(sw_min)
    {
        ffc_period = 0;
        ffc_mode = 0;
    }
    
    sensor_class(std::vector<uint8_t> data)
    {
        fw_maj_rev = data[1]<<8 | data[0];
        fw_min_rev = data[3]<<8 | data[2];
        sw_maj_rev = data[5]<<8 | data[4];
        sw_min_rev = data[7]<<8 | data[6];
        
        ffc_period = 0;
        ffc_mode = 0;        
    }
    
    //-----------------------------------------------------------------------------
    /**
    @brief Get the sensor version.

    This function builds a fip protocol packet to retrieve the camera sensor version.

    @param[out] fip_protocol that contains the structure to retrieve the sensor version.

    @note The returned data will contain the FW Major Revision, FW Minor Revision, SW Major Version, SW Minor Version.

    @sa fip_protocol, wind_protocol
    */
    fip_protocol get_version(void)
    {
        wind_protocol lens_packet(SENSOR_VERSION);
        
        // build a fip packet
        return fip_protocol(0x3D, lens_packet.to_array());
    }

    //-----------------------------------------------------------------------------
    /**
    @brief Perform Flat Field Correction.

    This function builds a fip protocol packet to perform a Flat Field Correction.

    The camera will perform a flat field correction based on the settings from the loaded NUC table. 
    
    The with lens blur FFC will block until the camera has started unblurring the lens. Without lens blur allows the user to call non-blocking calls, or to use a different flat field to perform an FFC.

    @param[in] value Type : 0 - with shutter close (default), 1 - with shutter open
    @param[out] fip_protocol that contains the structure to set the FFC mode.

    @sa fip_protocol, wind_protocol
    */
    fip_protocol perform_ffc(uint8_t value)
    {
        wind_protocol lens_packet(FLAT_FIELD_CORR);
        lens_packet.update_payload(value);
        
        // build a fip packet
        return fip_protocol(0x3D, lens_packet.to_array());
    }

    //-----------------------------------------------------------------------------
    /**
    @brief Set Auto FFC Period.

    This function builds a fip protocol packet to set the auto FFC period.

    @param[in] value Period : 10-1800 (in seconds) : 0 - off
    @param[out] fip_protocol that contains the structure to set the FFC period.

    @sa fip_protocol, wind_protocol
    */
    fip_protocol set_auto_ffc_period(uint8_t value)
    {
        wind_protocol lens_packet(SET_AUTO_FFC_PER);
        lens_packet.update_payload(value);
        
        // build a fip packet
        return fip_protocol(0x3D, lens_packet.to_array());
    }

    //-----------------------------------------------------------------------------
    /**
    @brief Get Auto FFC Period.

    This function builds a fip protocol packet to get the auto FFC period.

    @param[out] fip_protocol that contains the structure to get the FFC period.

    @sa fip_protocol, wind_protocol
    */
    fip_protocol get_auto_ffc_period(void)
    {
        wind_protocol lens_packet(GET_AUOT_FFC_PER);
        
        // build a fip packet
        return fip_protocol(0x3D, lens_packet.to_array());
    }

    //-----------------------------------------------------------------------------
    /**
    @brief Set Auto FFC Mode.

    This function builds a fip protocol packet to set whether the auto FFC will be performed with or without the shutter closing.

    @param[in] value Mode : 0 - with shutter close, 1 - without shutter close
    @param[out] fip_protocol that contains the structure to set the FFC mode.

    @sa fip_protocol, wind_protocol
    */
    fip_protocol set_auto_ffc_mode(uint8_t value)
    {
        wind_protocol lens_packet(SET_AUTO_FFC_MODE);
        lens_packet.update_payload(value);

        // build a fip packet
        return fip_protocol(0x3D, lens_packet.to_array());
    }

    //-----------------------------------------------------------------------------
    /**
    @brief Get Auto FFC mode.

    This function builds a fip protocol packet to get the auto FFC period.

    @param[out] fip_protocol that contains the structure to get the FFC mode.

    @sa fip_protocol, wind_protocol
    */
    fip_protocol get_auto_ffc_mode(void)
    {
        wind_protocol lens_packet(LENS_VERSION);

        // build a fip packet
        return fip_protocol(0x3D, lens_packet.to_array());
    }
    
    //-----------------------------------------------------------------------------
    /**
    @brief Set shutter.

    This function builds a fip protocol packet to set the shutter open or closed. 
    
    Sending this command will turn off automatic NUC. To re-enable NUC, set the NUC period to the desired value.

    @param[in] value shutterPosition : 0 - close, 1 - open
    @param[out] fip_protocol that contains the structure to set the shutter position.

    @sa fip_protocol, wind_protocol
    */
    fip_protocol set_shutter(uint8_t value)
    {
        wind_protocol lens_packet(SET_SHUTTER);
        lens_packet.update_payload(value);

        // build a fip packet
        return fip_protocol(0x3D, lens_packet.to_array());
    }

    //-----------------------------------------------------------------------------   
    /**
    @brief Get sensor ready.

    This function builds a fip protocol packet to get the status of the sensor.

    @param[out] fip_protocol that contains the structure to get the status of the sensor.

    @sa fip_protocol, wind_protocol
    */
    fip_protocol ready(void)
    {
        wind_protocol lens_packet(GET_SENSOR_READY);

        // build a fip packet
        return fip_protocol(0x3D, lens_packet.to_array());
    }

    //-----------------------------------------------------------------------------
    /**
    @brief Load NUC Table.

    This function builds a fip protocol packet to load the corresponding NUC table from the sensor.

    @param[in] value Table Number : (0-3)
    @param[out] fip_protocol that contains the structure to load a NUC table.

    @sa fip_protocol, wind_protocol
    */
    fip_protocol load_nuc_table(uint8_t value)
    {
        wind_protocol lens_packet(LOAD_NUC_TABLE);
        lens_packet.update_payload(value);

        // build a fip packet
        return fip_protocol(0x3D, lens_packet.to_array());
    }

    //-----------------------------------------------------------------------------
    /**
    @brief Get NUC Table.

    This function builds a fip protocol packet to get the currently loaded NUC table from the sensor.

    @param[out] fip_protocol that contains the structure to get the currently loaded NUC table.

    @sa fip_protocol, wind_protocol
    */
    fip_protocol get_nuc_table(void)
    {
        wind_protocol lens_packet(GET_NUC_TABLE);

        // build a fip packet
        return fip_protocol(0x3D, lens_packet.to_array());
    }

    //-----------------------------------------------------------------------------    
    inline friend std::ostream& operator<< (
        std::ostream& out,
        const sensor_class& item
    )
    {
        out << "  Firmware Version: " << (uint32_t)item.fw_maj_rev << "." << (uint32_t)item.fw_min_rev << std::endl;
        out << "  Software Version: " << (uint32_t)item.sw_maj_rev << "." << (uint32_t)item.sw_min_rev << std::endl;
        out << "  FFC Period:       " << (uint32_t)item.ffc_period << std::endl;
        out << "  FFC Mode:         " << (uint32_t)item.ffc_mode << std::endl;
        return out;
    }
    
};  // end sensor class

//-----------------------------------------------------------------------------
/** @brief Sierra Olympic Camera Class

This class build the packets in the to communicate with the camera.
*/
class so_camera{

public:
    uint8_t maj_rev;
    uint8_t min_rev;
    uint16_t build_num;
    uint16_t camera_type;
    
    lens_class lens;
    sensor_class sensor;
    

    so_camera() = default;
    
    so_camera(uint8_t maj_r, uint8_t min_r, uint16_t bn, uint16_t ct) : maj_rev(maj_r), min_rev(min_r), build_num(bn), camera_type(ct)
    {
        lens = lens_class();
        sensor = sensor_class();
    } 

    //-----------------------------------------------------------------------------
    /**
    @brief Get the camera version.

    This function builds a fip protocol packet to retrieve the camera version.

    @param[out] fip_protocol that contains the structure to retrieve the camera version.

    @note The returned data will contain the Major Revision, Minor Revision, Build Number, Camera Type.

    @sa fip_protocol, wind_protocol
    */
    fip_protocol get_version(void)
    {
        wind_protocol lens_packet(GET_CAMERA_VER);

        // build a fip packet
        return fip_protocol(0x3D, lens_packet.to_array());
    }
    
    //-----------------------------------------------------------------------------
    /**
    @brief End Camera Control.

    This function builds a fip protocol packet to end the application controlling the camera. The only way to restart the app is to power cycle the camera.

    @param[out] fip_protocol that contains the structure to end the camera app.

    @sa fip_protocol, wind_protocol
    */
    fip_protocol end_cam_control(void)
    {
        wind_protocol lens_packet(END_CAMERA_CTRL);

        // build a fip packet
        return fip_protocol(0x3D, lens_packet.to_array());
    }

    //-----------------------------------------------------------------------------    
    inline friend std::ostream& operator<< (
        std::ostream& out,
        const so_camera& item
    )
    {
        out << "Camera:" << std::endl;
        out << "  Firmware Version: " << (uint32_t)item.maj_rev << "." << (uint32_t)item.min_rev << (uint32_t)item.build_num << (uint32_t)item.camera_type << std::endl;
        out << "Lens" << std::endl;
        out << item.lens;
        out << "Sensor" << std::endl;
        out << item.sensor << std::endl;
        return out;
    }

private:

};  // end camera class


#endif  // _SO_CAM_COMMANDS_H_
