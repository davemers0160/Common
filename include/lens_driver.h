#ifndef LENS_DRIVER_CLASS_H
#define LENS_DRIVER_CLASS_H

#if defined(_WIN32) | defined(__WIN32__) | defined(__WIN32) | defined(_WIN64) | defined(__WIN64)
#define _CRT_SECURE_NO_WARNINGS
#define _SCL_SECURE_NO_WARNINGS
#endif

#include "ftdi_functions.h"


#include <cstdint>
#include <memory>
#include <string>
#include <vector>
#include <iterator>

#define MAX_DATA_LENGTH		16
#define MAX_PACKET_LENGTH	(MAX_DATA_LENGTH+4)

#define FOCUS_VOLTAGE_MIN	10.0
#define FOCUS_VOLTAGE_MAX	62.075	

#define LED_OPS     0x20        /* Used to control the LED on the board */

#define CON         0x40        /* Used to determine connection to the PIC */
#define GET_FW      0x41        /* Used to get firmware version of the PIC */
#define GET_SN      0x42        /* Used to get serial number of the PIC */
#define GET_DRV     0x43        /* Used to get the Lens Driver Chip */
#define GET_I2C     0x44        /* Used to get the current I2C error status */
#define GET_AMP     0x45        /* Used to get the current voltage setting stored by the PIC */

#define SET_VOLT    0x50        /* Used to set the voltage level for the driver */
#define FAST_SET_VOLT  0x51     /* Used to set the voltage level for the driver/ no response back from PIC */

typedef struct
{
    uint8_t serial_number;
    uint8_t firmware[2];
    uint8_t driver_type;
} lens_driver_info_struct;

struct lens_packet_struct
{
    uint8_t start;
    uint8_t command;
    uint8_t byte_count;
    std::vector<uint8_t> data;
    uint16_t checksum;


    lens_packet_struct() : start('$'), command(0), byte_count(0)
    {
        data.clear();
        checksum = 0;
    }

    lens_packet_struct(uint8_t com, uint8_t bc) : start('$')
    {
        command = com;
        byte_count = bc;
        checksum = 0;
    }

    lens_packet_struct(uint8_t com, uint8_t bc, std::vector<uint8_t> d) : start('$')
    {
        command = com;
        byte_count = bc;
        data = d;
        checksum = 0;
    }
};


class lens_driver
{

    public:
        //lens_driver() 
        //{
        //    lens_tx = lens_packet_struct();
        //    lens_rx = lens_packet_struct();
        //}

        lens_driver_info_struct lens_driver_info;
        lens_packet_struct lens_tx;
        lens_packet_struct lens_rx;

        void set_lens_driver_info(uint8_t sn, uint8_t fw[], uint8_t dt)
        {
            lens_driver_info.serial_number = sn;
            lens_driver_info.firmware[0] = fw[0];
            lens_driver_info.firmware[1] = fw[1];
            lens_driver_info.driver_type = dt;
        }

        void set_lens_driver_info(lens_packet_struct Packet)
        {
            lens_driver_info.serial_number = Packet.data[0];
            lens_driver_info.firmware[0] = Packet.data[1];
            lens_driver_info.firmware[1] = Packet.data[2];
            lens_driver_info.driver_type = Packet.data[3];
        }
    
        lens_driver_info_struct get_lens_driver_info(void) { return lens_driver_info; }
    
        uint8_t get_amplitude(void) { return amplitude; }

        void set_amplitude(uint8_t a) { amplitude = a; }

	    uint8_t send_lens_packet(lens_packet_struct Packet, FT_HANDLE lens_driver)
        {
            unsigned long dwBytesWritten;
            uint8_t data[MAX_PACKET_LENGTH];
            FT_STATUS ftStatus;

            data[0] = Packet.start;
            data[1] = Packet.command;
            data[2] = Packet.byte_count;
            for (uint8_t idx = 0; idx < Packet.data.size(); ++idx)
                data[3 + idx] = Packet.data[idx];

            ftStatus = FT_Write(lens_driver, data, Packet.byte_count + 3, &dwBytesWritten);
            if (ftStatus != FT_OK)
            {
                dwBytesWritten = 0;
            }

            return (uint8_t)dwBytesWritten;

        }	// end of send_lens_packet



        bool receive_lens_packet(lens_packet_struct &Packet, FT_HANDLE lens_driver, uint8_t count)
        {
            bool status = false;
            unsigned long dwRead = 0;
            uint8_t rx_data[MAX_PACKET_LENGTH] = { 0 };
            uint8_t idx;
            FT_STATUS ftStatus;

            //ReadFile(lensDriver, rx_data, count, (LPDWORD)&dwRead, &osReader);
            ftStatus = FT_Read(lens_driver, rx_data, count, &dwRead);

            if (dwRead > 0)
            {
                Packet.command = rx_data[0];
                Packet.byte_count = rx_data[1];
                Packet.data.clear();

                for (idx = 0; idx < Packet.byte_count - 2; ++idx)
                {
                    Packet.data.push_back(rx_data[idx + 2]);
                }
                Packet.checksum = (rx_data[idx + 2] << 8) | rx_data[idx + 3];

                status = verify_checksum(Packet);
                if (status == false)
                {
                    std::cout << "Checksum in data packet does not match." << std::endl;
                }
            }
            else
            {
                std::cout << "No data received from Lens Driver." << std::endl;
                status = false;
            }

            return status;

        }   // end of receive_lens_packet
      


// ----------------------------------------------------------------------------------------

    private:
        uint8_t amplitude;

        uint16_t gen_checksum(lens_packet_struct Packet)
        {

            uint16_t sum1 = 0;
            uint16_t sum2 = 0;
            uint16_t checksum;

            // calculate the sums - Command
            sum1 = (sum1 + Packet.command) % 255;
            sum2 = (sum2 + sum1) % 255;

            // calculate the sums - ByteCount
            sum1 = (sum1 + Packet.byte_count) % 255;
            sum2 = (sum2 + sum1) % 255;

            // calculate for data
            for (uint32_t idx = 0; idx < Packet.byte_count - 2; ++idx)
            {
                sum1 = (sum1 + Packet.data[idx]) % 255;
                sum2 = (sum2 + sum1) % 255;
            }

            // generate final checksum
            checksum = (sum2 << 8) | (sum1 & 0x00FF);

            return checksum;

        }   // end of gen_checksum



        bool verify_checksum(lens_packet_struct Packet)
        {
            bool status = false;

            uint16_t sum1 = 0;
            uint16_t sum2 = 0;

            uint16_t checksum = gen_checksum(Packet);

            if (Packet.checksum == checksum)
            {
                status = true;
            }
            return status;

        }   // end of check




	// variable declarations
	// struct LensDriverInfo
	// {

		// unsigned char SerialNumber;
		// unsigned char FirmwareVersion[2];
		// unsigned char DriverType;
		// unsigned char Amplitude;

		// LensDriverInfo()
		// {
			// SerialNumber = 0;
			// FirmwareVersion[0] = 0;
			// FirmwareVersion[1] = 0;
			// DriverType = 0;
			// Amplitude = 0;
		// }

    



	// struct LensRxPacket
	// {
		// unsigned char Command;
		// unsigned char ByteCount;
		// unsigned char Data[MAX_DATA_LENGTH];
		// unsigned short Checksum;

		// LensRxPacket()
		// {
			// Command = 0;
			// ByteCount = 0;
			// Checksum = 0;
			// memset(Data, 0, MAX_DATA_LENGTH);
		// }

		// LensRxPacket(unsigned char com, unsigned char bc)
		// {
			// Command = com;
			// ByteCount = bc;
			// memset(Data, 0, MAX_DATA_LENGTH);
			// Checksum = 0;
		// }

		// LensRxPacket(unsigned char com, unsigned char bc, unsigned char data[])
		// {
			// Command = com;
			// ByteCount = bc;
			// std::copy(data, data + bc, Data);
			// Checksum = 0;
		// }
	// };


	// struct LensTxPacket
	// {
		// unsigned char Start;
		// unsigned char Command;
		// unsigned char ByteCount;
		// unsigned char Data[MAX_DATA_LENGTH];


		// LensTxPacket()
		// {
			// Start = '$';
			// Command = 0;
			// ByteCount = 0;
			// memset(Data, 0, MAX_DATA_LENGTH);
		// }

		// LensTxPacket(unsigned char com, unsigned char bc)
		// {
			// Start = '$';
			// Command = com;
			// ByteCount = bc;
			// memset(Data, 0, MAX_DATA_LENGTH);
		// }

		// LensTxPacket(unsigned char com, unsigned char bc, unsigned char data[])
		// {
			// Start = '$';
			// Command = com;
			// ByteCount = bc;
			// std::copy(data, data + bc, Data);
		// }
	// };

	// struct LensFocus
	// {
		// unsigned char Focus[2];

		// LensFocus()
		// {
			// Focus[0] = 0;
			// Focus[1] = 0;
		// }

		// LensFocus(unsigned char F, unsigned char D)
		// {
			// Focus[0] = F;
			// Focus[1] = D;
		// }

		// LensFocus(double F, double D)
		// {
			// Focus[0] = setVoltage(F);
			// Focus[1] = setVoltage(D);
		// }
		// unsigned char setVoltage(double volts);
		// double getVoltage(unsigned char data);

	// };

	


	//unsigned short genChecksum(LensTxPacket Packet);
	//bool checkChecksum(LensRxPacket Packet);

	//void getLensDriverInfo(LensDriverInfo *LensInfo, LensRxPacket Packet);
	//void PrintDriverInfo(LensDriverInfo *LensInfo);

    

};  // end of class

// ----------------------------------------------------------------------------------------

inline std::ostream& operator<< (
    std::ostream& out,
    const lens_driver& item
    )
{
    using std::endl;
	out << "Lens Driver Information: " << std::endl;
    out << "  Serial Number:    " << (uint32_t)item.lens_driver_info.serial_number << std::endl;
    out << "  Firmware Version: " << (uint32_t)item.lens_driver_info.firmware[0] << "." << std::setfill('0') << std::setw(2) << (uint32_t)item.lens_driver_info.firmware[1] << std::endl;
    out << "  Driver Type:      Microchip HV892" << std::endl;
    return out;
}

// ----------------------------------------------------------------------------------------	


#endif
