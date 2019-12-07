#ifndef _DLIB_PSO_H
#define _DLIB_PSO_H

#include <ctime>
#include <cstdint>
#include <cmath>
#include <cstdlib>
#include <vector>
#include <algorithm>
#include <limits>
#include <iostream>
#include <iomanip>
#include <istream>

// dlib includes
#include <dlib/rand.h>
#include <dlib/threads.h>
#include <dlib/matrix.h>
#include <dlib/serialize.h>


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

        unsigned int N;                 // number of parameters in a population member
        long max_iterations;     // maximum number of iterations to perform

        unsigned int mode;               // which velocity update equation should be used

        pso_options() = default;

        pso_options(
            unsigned int N_,
            long max_iterations_,
            double c1_,
            double c2_,
            double w_,
            unsigned int mode_ = 0,
            double eph_ = 1e-4) : mode(mode_), epsilon(eph_)
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
                case 1:             // velocity constriction form
                    w = 1.0;

                    // calculate the constriction factor based on the following formula:
                    //   kap = 2/(abs(2 - phi - sqrt(phi^2 - 4*phi)))
                    phi = c1 + c2;
                    k = 2.0 / std::abs(2.0 - phi - std::sqrt(std::abs(phi * (phi - 4.0))));
                    break;

                default:            // canonical form
                    w = w_;
                    k = 1.0;
                    break;
            }

        }

        // ----------------------------------------------------------------------------------------
        inline friend std::ostream& operator<< (
            std::ostream& out,
            const pso_options &item
            )
        {
            //using std::endl;
            out << "pso_options details: " << std::endl;
            out << "  N:       " << item.N << std::endl;
            out << "  c1:      " << item.c1 << std::endl;
            out << "  c2:      " << item.c2 << std::endl;
            out << "  w:       " << item.w << std::endl;
            out << "  k:       " << item.k << std::endl;
            out << "  epsilon: " << item.epsilon << std::endl;
            out << "  max_itr: " << item.max_iterations << std::endl;
            out << "  mode:    " << item.mode << std::endl;
            return out;
        }

        // ----------------------------------------------------------------------------------------
        friend inline void serialize(const pso_options& item, std::ostream& out)
        {
            dlib::serialize("pso_options", out);
            dlib::serialize(item.N, out);
            dlib::serialize(item.c1, out);
            dlib::serialize(item.c2, out);
            dlib::serialize(item.w, out);
            dlib::serialize(item.k, out);
            dlib::serialize(item.epsilon, out);
            dlib::serialize(item.max_iterations, out);
            dlib::serialize(item.mode, out);
        }

        // ----------------------------------------------------------------------------------------
        friend inline void deserialize(pso_options& item, std::istream& in)
        {
            std::string version;
            dlib::deserialize(version, in);
            if (version != "pso_options")
                throw dlib::serialization_error("Unexpected version found: " + version + " while deserializing pso_options.");
            dlib::deserialize(item.N, in);
            dlib::deserialize(item.c1, in);
            dlib::deserialize(item.c2, in);
            dlib::deserialize(item.w, in);
            dlib::deserialize(item.k, in);
            dlib::deserialize(item.epsilon, in);
            dlib::deserialize(item.max_iterations, in);
            dlib::deserialize(item.mode, in);
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

        void set_syncfile(std::string filename)
        {
            sync_filename = filename;
        }

        // ----------------------------------------------------------------------------------------
        void init(std::pair<T, T> p_lim, std::pair<T, T> v_lim)
        {

            particle_limits = p_lim;
            velocity_limits = v_lim;

            iteration = 0;

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
            for (unsigned int idx = 0; idx < options.N; ++idx)
            {
                F[idx] = std::numeric_limits<double>::max();

                X[idx].rand_init(rnd, particle_limits);
                V[idx].rand_init(rnd, velocity_limits);
                X[idx].set_number(idx);
            }

        }	// end of init	

    // ----------------------------------------------------------------------------------------

        template<typename objective_function>
        void run(objective_function f)
        {

            double f_res;
            unsigned int idx;

            while (iteration < options.max_iterations)
            {
                // evaluate X in the objective function
                for (idx = 0; idx < options.N; ++idx) {
                    //dlib::parallel_for(0, options.N, [&](unsigned int idx) {
                    f_res = f(X[idx]);

                    if (f_res <= F[idx])
                    {
                        F[idx] = f_res;
                        P[idx] = X[idx];
                    }

                    //});
                }

                idx = std::min_element(F.begin(), F.end()) - F.begin();
                if (F[idx] <= g_best)
                {
                    g_best = F[idx];
                    G = X[idx];
                }


                // once the global best has been found we can know update the velocity 
                //for (idx = 0; idx < options.N; ++idx)
                dlib::parallel_for(0, options.N, [&](unsigned int idx) {
                    update_particle(idx);
                    });

                sync_to_disk();
                print_iteration();

                //std::cout << "conv: " << calc_convergence()*100 << "%" << std::endl;

                ++iteration;
            }

        }   // end of run

    // ----------------------------------------------------------------------------------------

    private:

        unsigned int iteration;
        pso_options options;
        dlib::rand rnd;

        std::pair<T, T> particle_limits;
        std::pair<T, T> velocity_limits;

        std::string sync_filename;

        std::vector<double> F;
        double g_best;

    // ----------------------------------------------------------------------------------------
        void print_iteration()
        {
            //std::cout << "Iteration: " << std::setfill('0') << std::setw(4) << iteration << ",  g_best: " << std::fixed << std::setprecision(6) << g_best << ",  G: " << G;
            std::cout << "Iteration: " << std::setfill('0') << std::setw(4) << iteration << ",  g_best: " << std::fixed << std::setprecision(6) << g_best << std::endl;
        }

    // ----------------------------------------------------------------------------------------
        void update_particle(unsigned int index)
        {
            // random 
            T R = options.c1 * T::get_rand_particle(rnd);
            T S = options.c2 * T::get_rand_particle(rnd);

            // velocity update function: V(k+1) = k*(w*V(k) + (c1*R)*(P(k) - X(k)) + (c2*S)*(G - X(k)))
            V[index] = options.k * ((options.w * V[index]) + (R * (P[index] - X[index])) + (S * (G - X[index])));
            V[index].limit_check(velocity_limits);

            // particle update function: X(k+1) = X(k) + V(k+1)
            X[index] = X[index] + V[index];
            X[index].limit_check(particle_limits);
            X[index].set_number(index);
            
        }   // end of update_particle

    // ----------------------------------------------------------------------------------------
        double calc_convergence()
        {
            unsigned int count = 0;

            for (unsigned int idx = 0; idx < options.N; ++idx)
            {

                //dlib::matrix<double> tmp = dlib::matrix_cast<double>(G) - dlib::matrix_cast<double>(X[idx]);

                //double dist = std::sqrt(dlib::dot(tmp, tmp));

                //if (dist <= options.epsilon)
                //    ++count;

            }

            return (double)count/(double)options.N;

        }   // end of calc_convergence

    // ----------------------------------------------------------------------------------------
        friend void serialize(const pso& item, std::ostream& out)
        {
            int version = 1;

            serialize(version, out);
            serialize(item.iteration, out);
            serialize(item.options, out);
            serialize(item.particle_limits.first, out);
            serialize(item.particle_limits.second, out);
            serialize(item.velocity_limits.first, out);
            serialize(item.velocity_limits.second, out);
            serialize(item.G, out);
            serialize(item.g_best, out);

            for (unsigned int idx = 0; idx < item.options.N; ++idx)
            {
                serialize(item.X[idx], out);
                serialize(item.V[idx], out);
                serialize(item.P[idx], out);
                serialize(item.F[idx], out);
            }

        }

    // ----------------------------------------------------------------------------------------

        friend void deserialize(pso& item, std::istream& in)
        {
            int version = 0;
            dlib::deserialize(version, in);
            if (version != 1)
                throw serialization_error("Unexpected version found while deserializing dlib::pso.");

            dlib::deserialize(item.iteration, in);
            dlib::deserialize(item.options, in);
            dlib::deserialize(item.particle_limits.first, in);
            dlib::deserialize(item.particle_limits.second, in);
            dlib::deserialize(item.velocity_limits.first, in);
            dlib::deserialize(item.velocity_limits.second, in);
            dlib::deserialize(item.G, in);
            dlib::deserialize(item.g_best, in);

            X.clear();
            V.clear();
            P.clear();
            F.clear();

            T tmp;
            double f_tmp;
            for (unsigned int idx = 0; idx < item.optins.N; ++idx)
            {
                dlib::deserialize(tmp, in); // X
                item.X.push_back(std::move(tmp));

                dlib::deserialize(tmp, in); // V
                item.V.push_back(std::move(tmp));

                dlib::deserialize(tmp, in); // P
                item.P.push_back(std::move(tmp));

                dlib::deserialize(tmp, in); // F
                item.F.push_back(f_tmp);
            }


        }

    // ----------------------------------------------------------------------------------------
        void sync_to_disk()
        {
            // If the sync file isn't set then don't save the progress
            if (sync_filename.size() == 0)
                return;

            dlib::serialize(sync_filename) << *this;

        }   // end of sync_to_disk
        

    };	// end of class

}   // end of namespace

#endif	// end of _DLIB_PSO_H
