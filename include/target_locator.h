#ifndef TARGET_LOCATOR_H_
#define TARGET_LOCATOR_H_

#include <cstdint>
#include <vector>
#include <list>
#include <algorithm>

#include "dlib/matrix.h"

// ----------------------------------------------------------------------------
typedef struct observation {

    float range = 0;
    std::vector<float> point;

    observation() = default;

    observation(float r_, std::vector<float> p_)
    {
        range = r_;
        point = p_;
    }

} observation;

// ----------------------------------------------------------------------------

class target_locator
{

public:

    // the unique identifier for the target
    uint32_t id;

    // location of the target <- most likely unknown
    std::vector<float> location;

    // observations of the target from a known position
    std::list<observation> obs;

    // variable to track is the location update was successful
    bool valid_location;

    // stop code list
    std::vector<std::string> stop_code_list { 
        "Minimum update error reached",                                         /*0*/
        "Maximum iterations reached",                                           /*1*/
        "Not enough observations to make an accurate position estimate",        /*2*/
        "No observations are recorded"                                          /*3*/
        }; 
        
    // ----------------------------------------------------------------------------
    target_locator() = default;

    target_locator(uint32_t id_) : id(id_) {}

    //target_locator(uint32_t id_, std::list<observation> obs_) : id(id_)
    //{
    //    obs = obs_;
    //}
    target_locator(uint32_t id_, observation obs_) : id(id_)
    {
        add_observation(obs_);
    }

    target_locator(uint32_t id_, observation obs_, std::vector<float> l_) : id(id_)
    {
        add_observation(obs_);
        location = l_;
    }

    // ----------------------------------------------------------------------------
    void set_max_observations(uint32_t m_) { max_observations = m_; }

    // ----------------------------------------------------------------------------
    void set_min_range(double m) { min_range = m; }

    double get_min_range(void) { return min_range; }

    // ----------------------------------------------------------------------------
    void set_location(std::vector<float> point_)
    {
        location.clear();
        location = point_;
    }

    // ----------------------------------------------------------------------------
    bool add_observation(observation new_obs)
    {
        bool add_obs = true;
        double r;
        for (observation o : obs)
        {
            r = get_range(o, new_obs.point);
            if (r < min_range)
                add_obs &= false;
        }

        if (add_obs)
        {
            obs.push_front(new_obs);
            if (obs.size() > max_observations)
            {
                obs.pop_back();
            }
        }

        return add_obs;

    }   // end of add_observation

    // ----------------------------------------------------------------------------
    double get_range(observation o1, std::vector<float> p1)
    {
        uint32_t idx;
        double r = 0;

        if (o1.point.size() != p1.size())
        {
            std::cout << "position dimensions do not match..." << std::endl;
            return r;
        }

        for (idx = 0; idx < o1.point.size(); ++idx)
        {
            r += (o1.point[idx] - p1[idx]) * (o1.point[idx] - p1[idx]);
        }

        return std::sqrt(r);

    }   // end of get_range

    //double get_range(std::vector<float> p1)
    //{
    //    uint32_t idx;
    //    double r = 0;

    //    if (location.size() != p1.size())
    //    {
    //        std::cout << "position dimensions do not match..." << std::endl;
    //        return r;
    //    }

    //    for (idx = 0; idx < location.size(); ++idx)
    //    {
    //        r += (double)(location[idx] - p1[idx]) * (double)(location[idx] - p1[idx]);
    //    }

    //    return std::sqrt(r);

    //}   // end of get_range

    // ----------------------------------------------------------------------------
    int32_t get_position()
    {
        uint32_t idx, jdx;
        int32_t stop_code = -1;

        float error = 1.0;
        float delta = 1.0e-4;
        uint32_t iteration = 0;
        uint32_t max_iteration = 30;

        valid_location = false;

        // run a check to make sure that the inputs are the same size
        if ((obs.size() == 0) || (obs.front().point.size() == 0))
        {
            //std::cout << "ranges and vehicles sizes do not match." << std::endl;
            return 3;
        }

        // check for the minimum number of observations, typically one more than the number of 
        // dimensions to solve for
        if (obs.size() < (obs.front().point.size() + 1))
        {
            //std::cout << "Not enough observations to make an accurate estimate of the position." << std::endl;
            return 2;
        }

        // use the current object position as the initial guess
        std::vector<float> Po(location);

        // get the matrix sizes R^(m x n):
        // - m is the number of observation measurements
        // - n is the number of dimensions that a position has (x,y,z,t,...) 
        uint32_t num_observations = obs.size();
        uint32_t num_dimensions = obs.front().point.size();

        dlib::matrix<float> A(num_observations, num_dimensions);
        dlib::matrix<float> b(num_observations, 1);
        dlib::matrix<float> x_hat;

        // this is an iterative least squares approach
        // looking to solve Ax = b => x = A^(-1)b
        while (stop_code < 0)
        {
            // build A matrix
            //for (idx = 0; idx < num_observations; idx++)
            idx = 0;
            for (observation o : obs)
            {
                for (jdx = 0; jdx < num_dimensions; ++jdx)
                {
                    // compute the partial derivatives and place into A matrix
                    A(idx, jdx) = -(o.point[jdx] - Po[jdx]) / (o.range);
                }

                // calculate delta P
                b(idx++, 0) = o.range - get_range(o, Po);
            }

            // x_hat = (((At*A)^-1)*At)*b
            x_hat = (dlib::pinv(dlib::trans(A) * A) * dlib::trans(A)) * b;

            // update the location estimate
            for (idx = 0; idx < num_dimensions; ++idx)
            {
                Po[idx] += x_hat(idx, 0);
            }

            error = std::sqrt(dlib::dot(x_hat, x_hat));
            ++iteration;

            if (error <= delta)
                stop_code = 0;      // this means that the error between the updates is small

            if (iteration >= max_iteration)
                stop_code = 1;      // this means that the maximum number of interations was reached

        }   // end of while loop

        // put the updated position back into object2
        set_location(Po);
        valid_location = true;
        return stop_code;

    }   // end of get_position

private:
    uint32_t max_observations = 20;
    double min_range = 1.0;

};  // end of target_locator

// ----------------------------------------------------------------------------

#endif	// TARGET_LOCATOR_H_
