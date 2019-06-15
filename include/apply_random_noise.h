#ifndef _APPLY_RANDOM_NOISE_H
#define _APPLY_RANDOM_NOISE_H

#include <cmath>
#include <cstdlib>
#include <cstdint>
#include <algorithm>

// dlib includes
#include <dlib/matrix.h>
#include <dlib/algs.h>

//-----------------------------------------------------------------------------

template<typename T, typename image_type>
void apply_random_noise(
    T lower_limit, 
    T upper_limit,
    image_type &img,
    dlib::rand &rnd,
    double std
)
{
    dlib::matrix<double, 6, 1> v;

    for (long r = 0; r < img[0].nr(); ++r)
    {
        for (long c = 0; c < img[0].nc(); ++c)
        {
            //v = rnd.get_random_gaussian(), rnd.get_random_gaussian(), rnd.get_random_gaussian(), rnd.get_random_gaussian(), rnd.get_random_gaussian(), rnd.get_random_gaussian();
            //v = dlib::round(std * v);

            v = rnd.get_integer_in_range(-std, std), rnd.get_integer_in_range(-std, std), rnd.get_integer_in_range(-std, std), rnd.get_integer_in_range(-std, std), rnd.get_integer_in_range(-std, std), rnd.get_integer_in_range(-std, std);

            img[0](r, c) = dlib::put_in_range(lower_limit, upper_limit, img[0](r, c) + v(0));
            img[1](r, c) = dlib::put_in_range(lower_limit, upper_limit, img[1](r, c) + v(1));
            img[2](r, c) = dlib::put_in_range(lower_limit, upper_limit, img[2](r, c) + v(2));
            img[3](r, c) = dlib::put_in_range(lower_limit, upper_limit, img[3](r, c) + v(3));
            img[4](r, c) = dlib::put_in_range(lower_limit, upper_limit, img[4](r, c) + v(4));
            img[5](r, c) = dlib::put_in_range(lower_limit, upper_limit, img[5](r, c) + v(5));
        }
    }

}

//-----------------------------------------------------------------------------

#endif // _APPLY_RANDOM_NOISE_H
