#ifndef _FIP_PROTOCOL_H_
#define _FIP_PROTOCOL_H_

#include <cstdint>

//-----------------------------------------------------------------------------
/** @brief FIP Protocol Class

This class builds FIP packets.
*/
class fip_protocol
{
    
public:

    uint8_t length;             // length includes type (1-byte), data (N-bytes) and checksum (1-byte)
    uint8_t type;
    uint8_t port;
    
    std::vector<uint8_t> data;

    fip_protocol() = default;
    
    fip_protocol(uint8_t t_, uint8_t p_ = 12) : type(t_), port(p_)
    {
        data.clear();
        length = 3;
        checksum = calc_checksum();
    }

    fip_protocol(uint8_t t_, std::vector<uint8_t> d_, uint8_t p_ = 12) : type(t_), port(p_)
    {
        data = d_;
        length = (uint8_t)(3 + data.size());
        checksum = calc_checksum();        
    }
    
    fip_protocol(std::vector<uint8_t> d_)
    {
        uint16_t idx, index = 0;
        
        if(d_[0] == header[0] && d_[1] == header[1])
        {
            if(d_[2] > 127)
            {
                length = (d_[3] << 7) | (d_[2] & ~0x80);
                index = 4;
            }
            else
            {
                length = d_[2];
                index = 3;
            }
            
            type = d_[index];
            
            for(idx=index; idx<d_.size()-1; ++idx)
            {
                data.push_back(d_[idx]);
            }
            
            checksum = d_[d_.size()-1];
                     
            checksum_valid = validate_checksum();

        }
        else
        {
            std::cout << "Error in supplied packet format. File: " << __FILE__ << ", line: " << __LINE__<< std::endl;
        }
        
    }

    //-----------------------------------------------------------------------------
    /**
    @brief to_array.

    This function converts the wind_protocol class to a uint8_t vector

    @return std::vector<uint8_t>

    */
    std::vector<uint8_t> to_array(void)
    {
        std::vector<uint8_t> d;

        std::copy(header.begin(), header.end(), std::back_inserter(d));

        if (length > 127)
        {
            d.push_back(length);
            d.push_back(0x01);
        }
        else
        {
            d.push_back(length);
        }

        d.push_back(type);

        d.push_back(port);
        
        d.insert(d.end(), data.begin(), data.end());

        d.push_back(checksum);

        return d;
    }
    
private:
    
    std::vector<uint8_t> header = { 0x51, 0xAC };
    uint8_t checksum;
    bool checksum_valid = true;

    //-----------------------------------------------------------------------------
    uint8_t calc_checksum(void)
    {
        uint8_t crc = 0x01;
        
        const int16_t crc8_table[ ] = {
                    0, 94, 188, 226, 97, 63, 221, 131, 194, 156, 126, 32, 163, 253, 31, 
                    65, 157, 195, 33, 127, 252, 162, 64, 30, 95, 1, 227, 189, 62, 96, 
                    130, 220, 35, 125, 159, 193, 66, 28, 254, 160, 225, 191, 93, 3, 128, 
                    222, 60, 98, 190, 224, 2, 92, 223, 129, 99, 61, 124, 34, 192, 158, 
                    29, 67, 161, 255, 70, 24, 250, 164, 39, 121, 155, 197, 132, 218, 56, 
                    102, 229, 187, 89, 7, 219, 133, 103, 57, 186, 228, 6, 88, 25, 71, 
                    165, 251, 120, 38, 196, 154, 101, 59, 217, 135, 4, 90, 184, 230, 167, 
                    249, 27, 69, 198, 152, 122, 36, 248, 166, 68, 26, 153, 199, 37, 123, 
                    58, 100, 134, 216, 91, 5, 231, 185, 140, 210, 48, 110, 237, 179, 81, 
                    15, 78, 16, 242, 172, 47, 113, 147, 205, 17, 79, 173, 243, 112, 46, 
                    204, 146, 211, 141, 111, 49, 178, 236, 14, 80, 175, 241, 19, 77, 206, 
                    144, 114, 44, 109, 51, 209, 143, 12, 82, 176, 238, 50, 108, 142, 208, 
                    83, 13, 239, 177, 240, 174, 76, 18, 145, 207, 45, 115, 202, 148, 118, 
                    40, 171, 245, 23, 73, 8, 86, 180, 234, 105, 55, 213, 139, 87, 9, 235, 
                    181, 54, 104, 138, 212, 149, 203, 41, 119, 244, 170, 72, 22, 233, 183, 
                    85, 11, 136, 214, 52, 106, 43, 117, 151, 201, 74, 20, 246, 168, 116, 
                    42, 200, 150, 21, 75, 169, 247, 182, 232, 10, 84, 215, 137, 107, 53
        };
        
        // calc checksum on type
        crc = crc8_table[crc^type];
        
        // calc checksum on port
        crc = crc8_table[crc ^ port];

        for(uint32_t idx=0; idx<data.size(); ++idx)
        {
            crc = crc8_table[crc^data[idx]];
        }            
        
        return crc;
        
    }   // end of calc_checksum
    
    //-----------------------------------------------------------------------------
    bool validate_checksum(void)
    {        
        return (checksum == calc_checksum());
    }

};  // end of fip_protocol class


#endif  // _FIP_PROTOCOL_H_
