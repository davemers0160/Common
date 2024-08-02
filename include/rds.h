#ifndef RDS_HEADER_H_
#define RDS_HEADER_H_

#if defined(_WIN32) | defined(__WIN32__) | defined(__WIN32) | defined(_WIN64) | defined(__WIN64)
// need for VS for pi and other math constatnts
#define _USE_MATH_DEFINES

#elif defined(__linux__)

#endif

// C/C++ includes
#include <cmath>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
//#include <ctime>
#include <vector>
#include <array>
//#include <complex>
#include <algorithm>
//#include <random>


const uint16_t PTY_SHIFT = 5;
const uint8_t NUM_BLOCKS = 4;
const int8_t BLOCK_SIZE = 16;
const int8_t CHECK_SIZE = 10;
const uint16_t POLY = 0x01B9;
const uint16_t POLY_DEG = 10;

//-----------------------------------------------------------------------------
enum RDS_GROUP_TYPE : uint16_t
{
	GT_0 = 0x00,
	GT_1 = (0x01 << 12),
	GT_2 = (0x02 << 12),
	GT_3 = (0x03 << 12),
	GT_4 = (0x04 << 12),
	GT_5 = (0x05 << 12),
	GT_6 = (0x06 << 12),
	GT_7 = (0x07 << 12),
	GT_8 = (0x08 << 12),
	GT_9 = (0x09 << 12),
	GT_10 = (0x0A << 12),
	GT_11 = (0x0B << 12),
	GT_12 = (0x0C << 12),
	GT_13 = (0x0D << 12),
	GT_14 = (0x0E << 12),
	GT_15 = (0x0F << 12)
};

//-----------------------------------------------------------------------------
enum RDS_VERSION : uint16_t
{
	A = 0x00,
	B = (0x01 << 11)
};

//-----------------------------------------------------------------------------
enum RDS_TP : uint16_t
{
	TP_0 = 0x00,			// Traffic announcements off
	TP_1 = (0x01 << 10)		// Traffic announcements on
};

//-----------------------------------------------------------------------------
enum RDS_TA : uint16_t
{
	TA_0 = 0x00,			// This program carries traffic announcements but none are being broadcast at present
	TA_1 = (0x01 << 4)		// A traffic announcement is being broadcast on this program at present
};

//-----------------------------------------------------------------------------
enum RDS_MS : uint16_t
{
	MS_0 = 0x00,			// speech
	MS_1 = (0x01 << 3)		// music
};

//-----------------------------------------------------------------------------
enum RDS_DI3 : uint16_t
{
	DI3_0 = 0x00,			// Static PTY
	DI3_1 = (0x01 << 2)		// PTY code on the tuned service, or referenced in EON variant 13, is dynamically switched
};

//-----------------------------------------------------------------------------
enum RDS_DI2 : uint16_t
{
	DI2_0 = 0x00,			// Not compressed
	DI2_1 = (0x01 << 2)		// Compressed
};

//-----------------------------------------------------------------------------
enum RDS_DI1 : uint16_t
{
	DI1_0 = 0x00,			// Not Artificial Head
	DI1_1 = (0x01 << 2)		// Artificial Head
};

//-----------------------------------------------------------------------------
enum RDS_DI0 : uint16_t
{
	DI0_0 = 0x00,			// Mono
	DI0_1 = (0x01 << 2)		// Stereo
};

//-----------------------------------------------------------------------------
template <typename T>
inline std::vector<T> differential_encode(std::vector<T> &data, T &previous_bit)
{
	uint64_t idx;
	std::vector<T> enc_data(data.size(), 0);

	for (idx = 0; idx < data.size(); ++idx)
	{
		enc_data[idx] = previous_bit ^ data[idx];
		previous_bit = enc_data[idx];
	}

	return enc_data;

}	// end of differential_encode

//-----------------------------------------------------------------------------
template <typename T>
inline std::vector<float> biphase_encode(std::vector<T>& data)
{
	uint64_t idx;

	float temp_data;
	std::vector<float> enc_data;

	// step 1: convert from 0/1 to polar (+/-1) and upsample by 2x
	for (idx = 0; idx < data.size(); ++idx)
	{
		temp_data = (2.0f * data[idx]) - 1.0f;
		enc_data.push_back(temp_data);
		enc_data.push_back(temp_data);
	}

	// step 2: shift by one sample and subtract
	for (idx = 1; idx < enc_data.size(); ++idx)
	{
		enc_data[idx] -= enc_data[idx-1];
	}

	// step 3: upsample and replace with pre computed bit waveform


	return {NULL};

}	// end of biphase_encode


//-----------------------------------------------------------------------------
class rds_block
{
public:
	uint16_t data = 0;
	uint16_t checkword = 0;

	rds_block() = default;

	rds_block(uint16_t d_) : data(d_) {}

	rds_block(uint16_t d_, uint16_t c_) : data(d_), checkword(c_) {}

	rds_block(const rds_block& b_) : data(b_.data), checkword(b_.checkword) {}

private:

};	// end of rds_block



//-----------------------------------------------------------------------------
class rds_block_1 : public rds_block
{
public:
	rds_block_1(uint16_t d_)
	{
		data = d_;
	}

private:

};

//-----------------------------------------------------------------------------
class rds_block_2 : public rds_block
{
public:

	rds_block_2(uint16_t type, uint16_t version, uint16_t tp, uint16_t pty, uint16_t d_)
	{
		data = type | version | tp | pty | d_;
	}

private:

};

//-----------------------------------------------------------------------------
class rds_block_3 : public rds_block
{
public:

	rds_block_3(uint16_t af1, uint16_t af2)
	{
		data = (af1 << 8) | af2;
	}

private:

};

//-----------------------------------------------------------------------------
class rds_block_4 : public rds_block
{
public:

	rds_block_4(uint16_t ps)
	{
		data = ps;
	}

	rds_block_4(uint8_t c0, uint8_t c1)
	{
		data = ((uint16_t)c0 << 8) | ((uint16_t)c1 & 0x00FF);
	}

private:

};

//-----------------------------------------------------------------------------
class rds_group
{
public:

	std::vector<rds_block> blocks;

	rds_group(rds_block b1, rds_block b2, rds_block b3, rds_block b4)
	{
		blocks.clear();
		blocks.resize(NUM_BLOCKS);
		blocks[0] = b1;
		blocks[1] = b2;
		blocks[2] = b3;
		blocks[3] = b4;

		calculate_checkword();
	}

	rds_group(std::vector<rds_block> blks)
	{
		blocks[0] = blks[0];
		blocks[1] = blks[1];
		blocks[2] = blks[2];
		blocks[3] = blks[3];
	}

	//-----------------------------------------------------------------------------
	std::vector<int16_t> to_bits()
	{
		uint8_t idx, jdx;
		uint16_t index = 0;

		std::vector<int16_t> bits(NUM_BLOCKS * 26, 0);

		// go through the block and checkword and create the bits
		for (idx = 0; idx < NUM_BLOCKS; ++idx)
		{
			for (jdx = 0; jdx < BLOCK_SIZE; ++jdx)
			{
				bits[index++] = ((blocks[idx].data >> ((BLOCK_SIZE-1) - jdx)) & 0x01);
			}

			for (jdx = 0; jdx < CHECK_SIZE; ++jdx)
			{
				bits[index++] = ((blocks[idx].checkword >> ((CHECK_SIZE-1) - jdx)) & 0x01);
			}
		}

		return bits;

	}	// end of to_bits

//-----------------------------------------------------------------------------
private:
	const std::vector<uint16_t> offset_words = {
		0x00FC, /*  A  */
		0x0198, /*  B  */
		0x0168, /*  C  */
		0x01B4, /*  D  */
		0x0350  /*  C' */
	};


	/* Calculate the checkword for each block and emit the bits */
	void calculate_checkword(void)
	{
		uint8_t idx, jdx;
		uint8_t bit, msb;
		uint16_t block, block_crc, check, offset_word;
		bool group_type_b = false;

		/* if b11 is 1, then type B */
		//if (IS_TYPE_B(blocks))
		//	group_type_b = true;

		std::vector<uint16_t> G = { 119, 743, 943, 779, 857, 880, 440, 220, 110, 55, 711, 959, 771, 861, 882, 441 };


		for (idx = 0; idx < NUM_BLOCKS; ++idx)
		{

			/* Group version B needs C' for block 3 */
			if (idx == 2 && group_type_b)
			{
				offset_word = offset_words[4];
			}
			else
			{
				offset_word = offset_words[idx];
			}

			block = blocks[idx].data;

			/* Classical CRC computation */
			//block_crc = 0;
			//for (jdx = 0; jdx < BLOCK_SIZE; ++jdx)
			//{
			//	bit = (block & (0x8000 >> jdx)) != 0;

			//	msb = (block_crc >> (POLY_DEG - 1)) & 1;

			//	block_crc <<= 1;

			//	if (msb ^ bit)
			//		block_crc ^= POLY;

			//	//*bits++ = bit;
			//}

			block_crc = 0;
			for (jdx = 0; jdx < BLOCK_SIZE; ++jdx)
			{
				if((block & (0x8000 >> jdx)))
				{
					block_crc ^= G[jdx];
				}
			}

			check = block_crc ^ offset_word;

			blocks[idx].checkword = check;

			//for (jdx = 0; jdx < POLY_DEG; ++jdx) 
			//{
			//	*bits++ = (check & ((1 << (POLY_DEG - 1)) >> jdx)) != 0;
			//}
		}
	}	// end of calculate_crc

};	// end of rds_group


#endif	// RDS_HEADER_H_
