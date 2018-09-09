#ifndef _CONFIG_NET_v8_H
#define _CONFIG_NET_v8_H

#include <cstdint>

// dlib includes
#include "dlib/dnn.h"
#include "dlib/dnn/core.h"


template <typename net_type>
void config_net_v8(net_type &net, std::vector<uint64_t> params)
{

    net = net_type(num_con_outputs(params[0]),
        num_con_outputs(params[1]),
        num_con_outputs(params[2]),
        num_con_outputs(params[3]),
        num_con_outputs(params[4]),
        num_con_outputs(params[5]),
        num_con_outputs(params[6]),
        num_con_outputs(params[7]),
        num_con_outputs(params[8]),
        num_con_outputs(params[9]),
        num_con_outputs(params[10]),
        num_con_outputs(params[11]),
        num_con_outputs(params[12]),
        num_con_outputs(params[13]),
        num_con_outputs(params[14]),
        num_con_outputs(params[15]),
        num_con_outputs(params[16]),
        num_con_outputs(params[17]),
        num_con_outputs(params[18]),
        num_con_outputs(params[19]),
        num_con_outputs(params[20]));

}   // end of config_net_v8

#endif  // _CONFIG_NET_v8_H
