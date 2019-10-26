#ifndef _DLIB_PSO_H
#define _DLIB_PSO_H

#include <ctime>
#include <cstdint>
#include <cmath>
#include <vector>
#include <algorithm>
#include <limits>
#include <iostream>
#include <iomanip>

// dlib includes
#include "dlib/rand.h"
#include "dlib/threads.h"
#include "dlib/matrix.h"


namespace dlib
{

    struct pso_options
    {
    public:

        double c1;                  // constant
        double c2;                  // constant
        double w;                   // 
        double k;                   // velocity constriction factor
        double epsilon;             // used to check for convergence between a particle and the global best particle

        uint32_t N;                 // number of parameters in a population member
        int32_t max_iterations;     // maximum number of iterations to perform

        uint8_t mode;               // which velocity update equation should be used

        pso_options() = default;

        pso_options(
            uint32_t N_,
            int32_t max_iterations_,
            double c1_,
            double c2_,
            double w_,
            uint8_t mode_ = 0,
            double eph_ = 1e-6) : mode(mode_), epsilon(eph_)
        {
            DLIB_CASSERT(c1_ > 0.0, "c1 must be greater than 0");
            DLIB_CASSERT(c2_ > 0.0, "c2 must be greater than 0");
            DLIB_CASSERT(w_ > 0.0, "w must be greater than 0");

            double phi = 0;

            N = N_;
            max_iterations = max_iterations_;
            c1 = c1_;
            c2 = c2_;

            switch(mode)
            {
                case  0:            // canonical form
                    w = w_;
                    k = 1.0;
                    break;

                case 1:             // velocity constriction form
                    w = 1.0;

                    // calculate the constriction factor based on the following formula:
                    //      kap = 2/(abs(2 - phi - sqrt(phi^2 - 4*phi)))
                    phi = c1 + c2;
                    k = 2.0 / std::abs(2.0 - phi - std::sqrt(std::abs(phi * (phi - 4.0))));
                    break;

                default:
                    w = w_;
                    k = 1.0;
                    break;
            }

        }

    };  // end of pso_options

    // ----------------------------------------------------------------------------------------

    template<typename T>
    class pso
    {

    public:

        // the particles that will search the space 
        std::vector<T> X;

        // the velocity of of each particle
        std::vector<T> V;

        // the particles that contains the best results for each population member
        std::vector<T> P;

        // the single particle that contains the best results for all population members and interations
        T G;

        // ----------------------------------------------------------------------------------------

        pso() {}
        pso(pso_options options_) : options(options_) {}

        // ----------------------------------------------------------------------------------------

        const pso_options& get_options() const { return options; }

        // ----------------------------------------------------------------------------------------

        //T get_P(uint32_t idx)
        //{
        //    return P[idx];
        //}

        //double get_G_best()
        //{
        //    return G_best;
        //}

        //T get_G()
        //{
        //    return G;
        //}

        // ----------------------------------------------------------------------------------------

        void init(std::pair<T, T> p_lim, std::pair<T, T> v_lim)
        {

            particle_limits = p_lim;
            velocity_limits = v_lim;

            itr = 0;

            // clear everything
            X.clear();
            V.clear();
            P.clear();
            F.clear();

            // set the particle sizes to the number of the population
            X.resize(options.N);
            V.resize(options.N);
            P.resize(options.N);
            F.resize(options.N);

            g_best = std::numeric_limits<double>::max();

            rnd = dlib::rand(time(NULL));

            // initialize each particle and velocity with random values within the supplied limits
            for (uint64_t idx = 0; idx < options.N; ++idx)
            {
                F[idx] = std::numeric_limits<double>::max();

                X[idx].rand_init(rnd, particle_limits);
                V[idx].rand_init(rnd, velocity_limits);

            }

        }	// end of init	

    // ----------------------------------------------------------------------------------------

        template<typename objective_function>
        void run(objective_function f(T))
        {

            double f_res;

            while (itr < options.max_iterations)
            {

                // evaluate X in the objective function
                for (uint32_t idx = 0; idx < options.N; ++idx)
                {
                    f_res = f(X[idx]);

                    if (f_res < F[idx])
                    {
                        F[idx] = f_res;
                        P[idx] = X[idx];

                        if (f_res < g_best)
                        {
                            g_best = f_res;
                            G = X[idx];
                        }

                    }

                }

                update_velocity();

                update_particle();

                print_iteration();

                //std::cout << "conv: " << calc_convergence()*100 << "%" << std::endl;

                ++itr;
            }

        }   // end of run

    // ----------------------------------------------------------------------------------------

    private:

        uint32_t itr;
        pso_options options;
        dlib::rand rnd;

        std::pair<T, T> particle_limits;
        std::pair<T, T> velocity_limits;

        std::vector<double> F;
        double g_best;

        void print_iteration()
        {
            std::cout << "Iteration: " << std::setfill('0') << std::setw(4) << itr << ",    g_best: " << std::fixed << std::setprecision(6) << g_best << ",    G: " << G << std::endl;
        }

    // ----------------------------------------------------------------------------------------

        void update_particle()
        {
            for (uint32_t idx = 0; idx < options.N; ++idx)
            {
                // particle update function: X(k+1) = X(k) + V(k+1)
                X[idx] = X[idx] + V[idx];

                X[idx].limit_check(particle_limits);
            }
        }   // end of update_particle


    // ----------------------------------------------------------------------------------------

        void update_velocity()
        {
            dlib::matrix<double> R;
            dlib::matrix<double> S;

            

            for (uint32_t idx = 0; idx < options.N; ++idx)
            {
                R = options.c1 * dlib::randm(X[idx].get_params(), 1, rnd);
                S = options.c2 * dlib::randm(X[idx].get_params(), 1, rnd);

                // velocity update function: V(k+1) = k*(w*V(k) + (c1*R)*(P(k) - X(k)) + (c2*S)*(G - X(k)))
                V[idx] = options.k * ((options.w * V[idx]) + (R * (P[idx] - X[idx])) + (S * (G - X[idx])));

                V[idx].limit_check(velocity_limits);
            
            }
        }   // end of update_velocity

    // ----------------------------------------------------------------------------------------

        double calc_convergence()
        {
            uint32_t count = 0;

            for (uint32_t idx = 0; idx < options.N; ++idx)
            {

                dlib::matrix<double> tmp = dlib::matrix_cast<double>(G) - dlib::matrix_cast<double>(X[idx]);

                double dist = std::sqrt(dlib::dot(tmp, tmp));

                if (dist <= options.epsilon)
                    ++count;

            }

            return (double)count/(double)options.N;
        }


    };	// end of class

}   // end of namespace

#endif	// end of _DLIB_PSO_H
