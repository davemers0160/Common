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
#include <ostream>
#include <iostream>
//#include <ctime>
#include <vector>
#include <array>
//#include <complex>
#include <algorithm>
//#include <random>

#include <dsp/dsp_windows.h>


const uint8_t NUM_BLOCKS = 4;
const int8_t BLOCK_SIZE = 16;
const int8_t CHECK_SIZE = 10;
const uint16_t POLY = 0x01B9;
const uint16_t POLY_DEG = 10;

const uint8_t GT_SHIFT = 12;
const uint8_t VER_SHIFT = 11;
const uint8_t TP_SHIFT = 10;
const uint8_t PTY_SHIFT = 5;
const uint8_t TA_SHIFT = 4;
const uint8_t TEXT_AB_SHIFT = 4;
const uint8_t MS_SHIFT = 3;
const uint8_t DI_SHIFT = 2;

const uint8_t group_0_num = 4;
const uint8_t group_2_num = 16;


//-----------------------------------------------------------------------------
enum RDS_GROUP_TYPE : uint16_t
{
	GT_0 = 0x00,
	GT_1 = 0x01,
	GT_2 = 0x02,
	GT_3 = 0x03,
	GT_4 = 0x04,
	GT_5 = 0x05,
	GT_6 = 0x06,
	GT_7 = 0x07,
	GT_8 = 0x08,
	GT_9 = 0x09,
	GT_10 = 0x0A,
	GT_11 = 0x0B,
	GT_12 = 0x0C,
	GT_13 = 0x0D,
	GT_14 = 0x0E,
	GT_15 = 0x0F
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
	TP_1 = 0x01				// Traffic announcements on
};

//-----------------------------------------------------------------------------
enum RDS_PTY : uint16_t
{
	NONE = 0,               /* No program type or undefined */
	NEWS = 1,               /* News */
	INFO = 2,               /* Information */
	SPORTS = 3,             /* Sports */
	TALK = 4,               /* Talk */
	ROCK = 5,               /* Rock */
	CLASSIC_ROCK = 6,       /* Classic Rock */
	ADULT_HITS = 7,         /* Adult Hits */
	SOFT_ROCK = 8,          /* Soft Rock */
	TOP_40 = 9,             /* Top 40 */
	COUNTRY = 10,           /* Country */
	OLDIES = 11,            /* Oldies */
	SOFT = 12,              /* Soft */
	NOSTALGIA = 13,         /* Nostalgia */
	JAZZ = 14,              /* Jazz */
	CLASSICAL = 15,         /* Classical */
	RNB = 16,               /* Rhythm and Blues */
	SOFT_RNB = 17,          /* Soft Rhythm and Blues */
	FOREIGN_LANGUAGE = 18,  /* Foreign Language */
	RELIGIOUS_MUSIC = 19,   /* Religious Music */
	RELIGIOUS_TALK = 20,    /* Religious Talk */
	PERSONALITY = 21,       /* Personality */
	PUBLIC = 22,            /* Public */
	COLLEGE = 23,           /* College */
	UNASSIGN_0 = 24,        /* Unassigned */
	UNASSIGN_1 = 25,        /* Unassigned */
	UNASSIGN_2 = 26,        /* Unassigned */
	UNASSIGN_3 = 27,        /* Unassigned */
	UNASSIGN_4 = 28,        /* Unassigned */
	WEATHER = 29,           /* Weather */
	EMERGENCY_TEST = 30,    /* Emergency Test */
	EMERGENCY_ALERT = 31    /* Emergency ALERT */
};

//-----------------------------------------------------------------------------
enum RDS_TA : uint16_t
{
	TA_0 = 0x00,			// This program carries traffic announcements but none are being broadcast at present
	TA_1 = 0x01				// A traffic announcement is being broadcast on this program at present
};

//-----------------------------------------------------------------------------
enum RDS_MS : uint16_t
{
	MS_0 = 0x00,			// speech
	MS_1 = 0x01				// music
};

//-----------------------------------------------------------------------------
enum RDS_DI3 : uint16_t
{
	DI3_0 = 0x00,			// Static PTY
	DI3_1 = 0x01			// PTY code on the tuned service, or referenced in EON variant 13, is dynamically switched
};

//-----------------------------------------------------------------------------
enum RDS_DI2 : uint16_t
{
	DI2_0 = 0x00,			// Not compressed
	DI2_1 = 0x01			// Compressed
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
template <typename T, typename U>
void apply_filter(std::vector<T>& data, std::vector<U>& filter, float amplitude, std::vector<float>& filtered_data)
{
	int32_t idx, jdx;
	int32_t dx = filter.size() >> 1;
	int32_t x;

	float accum;

	filtered_data.clear();
	filtered_data.resize(data.size(), 0.0);

	// loop throught the data and the filter and convolve (assumes a symmetric filter so no flip required)
	for (idx = 0; idx < data.size(); ++idx)
	{
		accum = 0.0;

		for (jdx = 0; jdx < filter.size(); ++jdx)
		{
			x = idx + jdx - dx;
			//std::complex<double> t1 = std::complex<double>(lpf[jdx], 0);
			//std::complex<double> t2 = iq_data[idx + jdx - offset];
			if (x >= 0 && x < data.size())
				accum += amplitude * data[x] * filter[jdx];
		}

		filtered_data[idx] = accum;
	}

}   // end of apply_filter

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

	//std::cout << std::endl << "data" << std::endl;
	//for (idx = 0; idx < data.size(); ++idx)
	//{
	//	std::cout << (data[idx]) << ", ";
	//}
	//std::cout << std::endl;

	//std::cout << std::endl << "diff encode" << std::endl;
	//for (idx = 0; idx < enc_data.size(); ++idx)
	//{
	//	std::cout << (enc_data[idx]) << ", ";
	//}
	//std::cout << std::endl;

	return enc_data;

}	// end of differential_encode

//-----------------------------------------------------------------------------
template <typename T>
std::vector<float> upsample_data(std::vector<T>& d, uint32_t factor, uint64_t sample_rate)
{
	uint64_t idx;
	uint64_t index = 0;

	uint64_t num_samples = d.size() * factor;

	std::vector<float> u(num_samples, 0.0f);

	for (idx = 0; idx < d.size(); ++idx)
	{
		u[index] = (float)d[idx];
		index += factor;
	}

	//// filter the data
	int64_t num_taps = 3*factor + 1;
	float fc = 2400.0/(float)sample_rate;

	std::vector<float> lpf = DSP::create_fir_filter<float>(num_taps, fc, &DSP::blackman_nuttall_window);
	
	std::vector<float> rds;
	apply_filter(u, lpf, (num_taps>>2), rds);

	return rds;

}   // end of upsample_data

//-----------------------------------------------------------------------------
template <typename T>
inline std::vector<float> biphase_encode(std::vector<T>& data)
{
	uint64_t idx;

	float temp_data;
	std::vector<float> tmp_data_v;
	std::vector<float> enc_data(2*data.size(), 0.0f);

	// step 1: convert from 0/1 to polar (+/-1) and upsample by 2x and turn into an impulse
	for (idx = 0; idx < data.size(); ++idx)
	{
		temp_data = (2.0f * data[idx]) - 1.0f;
		tmp_data_v.push_back(temp_data);
		tmp_data_v.push_back(0);
	}

	//std::cout << std::endl << "biphase 1" << std::endl;
	//for (idx = 0; idx < tmp_data_v.size(); ++idx)
	//{
	//	std::cout << (tmp_data_v[idx]) << ", ";
	//}
	//std::cout << std::endl;

	// step 2: shift by one sample and subtract
	enc_data[0] = tmp_data_v[0];
	for (idx = 1; idx < enc_data.size(); ++idx)
	{
		enc_data[idx] = tmp_data_v[idx] - tmp_data_v[idx-1];
	}

	return enc_data;

}	// end of biphase_encode

//-----------------------------------------------------------------------------
typedef struct rds_params
{
	uint16_t pi_code;
	uint16_t version;
	uint16_t tp;
	uint16_t pty;
	uint16_t ta;
	uint16_t ms;

	rds_params() = default;

	//rds_params(uint16_t pi_, uint16_t v_, uint16_t tp_, uint16_t pty_, uint16_t ta_, uint16_t ms_) : pi_code(pi_)
	//{
	//	version = (v_ & 0x0001) << VER_SHIFT;
	//	tp = (tp_ & 0x0001) << TP_SHIFT;
	//	pty = (pty_ & 0x0007) << PTY_SHIFT;
	//	ta = (ta_ & 0x0001) << TA_SHIFT;
	//	ms = (ms_ & 0x0001) << MS_SHIFT;
	//}

	rds_params(uint16_t pi_, uint16_t v_, uint16_t tp_, uint16_t pty_, uint16_t ta_, uint16_t ms_) :
		pi_code(pi_), version(v_), tp(tp_), pty(pty_), ta(ta_), ms(ms_) {}

	rds_params(const rds_params& rp_) : pi_code(rp_.pi_code), version(rp_.version), tp(rp_.tp),
		pty(rp_.pty), ta(rp_.ta), ms(rp_.ms) {}

} rds_params;

//-----------------------------------------------------------------------------
class rds_block
{
public:
	uint16_t data = 0;
	uint16_t checkword = 0;

	rds_block() = default;

	rds_block(uint16_t d_) : data(d_) {}

	//rds_block(uint16_t d_, uint16_t c_) : data(d_), checkword(c_) {}

	rds_block(uint16_t c0, uint16_t c1)
	{
		data = ((c0 & 0x00FF) << 8) | (c1 & 0x00FF);
	}

	rds_block(const rds_block& b_) : data(b_.data), checkword(b_.checkword) {}

	friend std::ostream& operator<<(std::ostream& out, const rds_block& b)
	{
		int8_t idx;

		out << "data:  ";
		for (idx = 15; idx >= 0; --idx)
		{
			out << ((b.data >> idx) & 0x01) << " ";
		}
		out << std::endl;

		out << "check: ";
		for (idx = 9; idx >= 0; --idx)
		{
			out << ((b.data >> idx) & 0x01) << " ";
		}
		out << std::endl;

		return out;
	}
private:

};	// end of rds_block

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
		blocks.clear();
		blocks.resize(NUM_BLOCKS);
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


class rds_generator
{

public:
	rds_params rds_param;

	rds_generator(rds_params &rp) : rds_param(rp)
	{
		//rds_param = rds_params(rp);
	}

	//----------------------------------------------------------------------------
	void init_generator(std::string pn, std::string rt)
	{
		uint8_t idx;

		update_program_name(pn);

		radio_text = rt;

		previous_bit = 0;

		create_group_0();
		create_group_2();

		// 4 group_0 for each group_2
		num_groups = 4 * group_2.size() + group_2.size();
	}

	//----------------------------------------------------------------------------
	void update_program_name(std::string pn)
	{
		uint16_t pn_buffer;

		std::string pgm_name_space = "        ";

		program_name.clear();
		program_name = pn;

		if (program_name.length() < 8)
		{
			pn_buffer = 8 - program_name.length();
			program_name.append(pgm_name_space, 0, pn_buffer);
		}
	}	// end of update_program_name

	//----------------------------------------------------------------------------
	void update_radio_text(std::string rt)
	{

	}

	//----------------------------------------------------------------------------
	std::vector<complex<int16_t>> generate_bit_stream()
	{
		uint32_t idx;
		uint32_t index = 0;
		std::vector<int16_t> data_bits;

		std::complex<float> j(0, 1);
		const float math_2pi = 6.283185307179586476925286766559f;

		group_0_index = 0;
		group_2_index = 0;

		// step 1: generate the binary bit stream
		while(index < num_groups)
		{
			for (idx = 0; idx < group_0_num; ++idx)
			{
				std::vector<int16_t> g0_bits = group_0[idx].to_bits();
				data_bits.insert(data_bits.end(), g0_bits.begin(), g0_bits.end());
				++index;
			}

			std::vector<int16_t> g2_bits = group_2[group_2_index++].to_bits();
			data_bits.insert(data_bits.end(), g2_bits.begin(), g2_bits.end());
			++index;

		}	// end of while

		// step 2: apply differential encoding
		data_bits = differential_encode(data_bits, previous_bit);

		// step 3: apply biphase encoding
		std::vector<float> data_bits_e = biphase_encode(data_bits);

		// step 4: upsample and filter the data
		std::vector<float> rds = upsample_data(data_bits_e, factor, sample_rate);

		// step 5: add the pilot tone and rotate the rds data
		float pilot_tone = 19000.0 / (float)sample_rate;
		float rds_tone = 57000.0 / (float)sample_rate;

		std::complex<float> pilot;
		std::complex<float> rds_rot;

		std::vector<complex<int16_t>> iq_data(rds.size(), std::complex<int16_t>(0, 0));

		for (idx = 0; idx < rds.size(); ++idx)
		{
			pilot = std::complex<float>(pilot_amplitude, 0.0f) * std::exp(j * math_2pi * (pilot_tone * idx));
			rds_rot = rds[idx] * std::exp(j * math_2pi * (rds_tone * idx));

			iq_data[idx] = std::complex<int16_t>(amplitude * (pilot + rds_rot));
		}

		return iq_data;

	}	// generate_bit_stream

//-----------------------------------------------------------------------------
private:
	uint16_t group_0_index = 0;
	uint16_t group_2_index = 0;
	std::vector<uint16_t> di = { 0, 0, 0, 1 };			// reverse order => {d3, d2, d1, d0}

	std::vector<rds_group> group_0;
	std::vector<rds_group> group_2;

	std::string program_name;

	uint16_t text_ab_flag = 0;
	std::string radio_text = "";

	uint16_t num_groups = 80;

	int16_t previous_bit = 0;
	uint32_t factor = 240;

	float pilot_amplitude = 0.08;
	float rds_amplitude = 0.20;

	const uint8_t samples_per_symbol = 2;

	uint64_t sample_rate = (1187.5 * samples_per_symbol) * factor;

	std::complex<float> amplitude = std::complex<float>(1200.0f, 0.0f);

	//-----------------------------------------------------------------------------
	void create_group_0()
	{
		uint8_t idx = 0;
		uint16_t block_data = 0;
		uint8_t pn_buffer;

		std::string pgm_name_space = "        ";
		uint8_t num_segments = 4;

		if (program_name.length() < 8)
		{
			pn_buffer = 8 - program_name.length();
			program_name.append(pgm_name_space, 0, pn_buffer);
		}

		group_0.clear();

		rds_block b1(rds_param.pi_code);
		rds_block b3(224, 205);				// no AF's right now
		rds_block b2;
		rds_block b4;

		// idx is the segment address
		for (idx = 0; idx < num_segments; ++idx)
		{
			block_data = (RDS_GROUP_TYPE::GT_0 << GT_SHIFT) | (rds_param.version << VER_SHIFT) | (rds_param.tp << TP_SHIFT) | (rds_param.pty << PTY_SHIFT) | (rds_param.ta << TA_SHIFT) | (rds_param.ms << MS_SHIFT) | (di[idx] << DI_SHIFT) | idx;
			b2 = rds_block(block_data);
			b4 = rds_block((uint8_t)(program_name[2*idx]), (uint8_t)(program_name[2*idx+1]));
			group_0.push_back(rds_group(b1, b2, b3, b4));
		}

	}	// end of create_group_0

	//-----------------------------------------------------------------------------
	void create_group_2()
	{
		uint32_t idx = 0;
		uint16_t block_data = 0;

		uint8_t character_index = 0;

		// determine how many characters there are
		uint16_t num_rt_characters = radio_text.length();
		num_rt_characters = min(num_rt_characters, 62);

		//TODO: append carriage  return
		//if (num_rt_characters & 0x01)
		//{
		//	radio_text.append("\r", 0, 1);
		//}
		//else
		//{
		//	radio_text.append(" \r", 0, 2);
		//}

		uint8_t num_segments = radio_text.length() >> 2;

		group_2.clear();

		rds_block b1(rds_param.pi_code);
		rds_block b2;
		rds_block b3;
		rds_block b4;

		text_ab_flag ^= 1;
		
		// idx is the segment address
		for (idx = 0; idx < num_segments; ++idx)
		{
			block_data = (RDS_GROUP_TYPE::GT_2 << GT_SHIFT) | (rds_param.version << VER_SHIFT) | (rds_param.tp << TP_SHIFT) | (rds_param.pty << PTY_SHIFT) | (text_ab_flag << TEXT_AB_SHIFT) | idx;
			b2 = rds_block(block_data);
			b3 = rds_block((uint16_t)(radio_text[character_index]), (uint16_t)(radio_text[character_index+1]));
			b4 = rds_block((uint16_t)(radio_text[character_index+2]), (uint16_t)(radio_text[character_index+3]));
			group_2.push_back(rds_group(b1, b2, b3, b4));

			character_index += 4;
		}

	}	// end of create_group_2

	//-----------------------------------------------------------------------------


};	// end or rds_generator


#endif	// RDS_HEADER_H_
