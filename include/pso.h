#ifndef PSO_H
#define PSO_H

#include <cstdint>
#include <vector>
#include <cmath>
#include <algorithm>
#include <ctime>
#include <limits>

// dlib includes
//#include <dlib/image_io.h>
//#include <dlib/data_io.h>
//#include <dlib/gui_widgets.h>
//#include <dlib/image_transforms.h>
//#include <dlib/image_transforms/interpolation.h>
#include "dlib/rand.h"
#include "dlib/threads.h"
#include "dlib/matrix.h"



class pso_handler
{

	public:
	
        pso_handler(uint64_t N_, uint64_t p_, uint64_t itr_, double c1_ = 2.0, double c2_=2.1 )
		{
			N = N_;
			c1 = c1_;
			c2 = c2_;
			p = p_;
			itr = itr_;

			
		}
		
// ----------------------------------------------------------------------------------------

		dlib::matrix<double> get_p_best()
		{			
			return P_best;
		}

        dlib::matrix<double> get_P()
        {
            return P;
        }

        void set_P(double val, uint64_t itr, uint64_t n)
        {
            P(itr, n) = val;
        }

        void set_P_best(dlib::matrix<double> &X, uint64_t p_idx)
        {
            P_best = dlib::colm(X, p_idx);
        }

		
		dlib::matrix<double> get_G_best()
		{
			return G_best;
		}

        double get_G()
        {
            return G;
        }

        void set_G_best(double G_, dlib::matrix<double> G_best_)
        {
            G = G_;
            G_best = G_best_;
        }

        

// ----------------------------------------------------------------------------------------

		void init(std::vector<std::pair<double,double>> x_lim, dlib::matrix<double> &X)
		{
			
				
                DLIB_CASSERT(c1 + c2 > 4.0, "\t c1 + c2 must be greater than 4.0");
				DLIB_CASSERT(N > 0, "\t Error: The number of population members (N) must be greater than 0");
				DLIB_CASSERT(p > 0, "\t Error: The number of parameters in a population member (p) must be greater than 0");
				DLIB_CASSERT(itr > 0, "\t Error: The number of iterations must be greater than 0");
				
				double phi = c1 + c2;
				//rnd.set_seed(time(NULL));
				
				k = 2.0/std::abs(2.0-phi-std::sqrt(phi*phi - 4));

                X.set_size(p, N);
                V.set_size(p, N);

                rnd = dlib::rand(time(0));
				
				for(uint64_t idx=0; idx<N; ++idx)
				{
                    //dlib::matrix<double> x_t(p, N);     // nr = p; nc = N 
                    //dlib::matrix<double> v_t(p, N);     // nr = p; nc = N 

					for (uint64_t jdx = 0; jdx < p; ++jdx)
					{

						//X(jdx, idx) = rnd.get_double_in_range(x_lim[jdx].first, x_lim[jdx].second);
                        V(jdx, idx) = rnd.get_double_in_range(-1.0,1.0);
					}

					//X.push_back(x_t);
					//V.push_back(v_t);
					
				}
				
				// resize the P_best/G_best matrix: nc = number of population members; nr = number of iterations
				P.set_size(itr,N);	
                G = dlib::DBL_MAX;


				
				P_best.set_size(p,1);
				G_best.set_size(p,1);
	
		}	// end of init	



// ----------------------------------------------------------------------------------------

        uint64_t get_P_min(uint64_t itr)
        {
            uint64_t p_idx = dlib::index_of_min(dlib::rowm(P, itr));
        }   //


        

        void update(dlib::matrix<double> &X, uint64_t itr, std::vector<std::pair<double, double>> v_lim, std::vector<std::pair<double, double>> x_lim)
        {
            // get the best P value for the current iteration

            uint64_t p_idx = dlib::index_of_min(dlib::rowm(P, itr));

            set_P_best(X, p_idx);

            if (P(itr, p_idx) <= G)
            {
                set_G_best(P(itr, p_idx), P_best);
            }
            else
            {
                set_G_best(G, G_best);
            }

            update_V(X, v_lim);

            update_X(X, x_lim);

            int bp = 0;

        }

        void update_V(dlib::matrix<double> X, std::vector<std::pair<double, double>> v_lim)
        {

            for (uint64_t idx = 0; idx < N; ++idx)
            {

                dlib::matrix<double> r = dlib::randm(p, 1);
                dlib::matrix<double> s = dlib::randm(p, 1);

                dlib::set_colm(V,idx) = k * ( dlib::colm(V,idx) + c1*dlib::pointwise_multiply(r,(P_best-dlib::colm(X,idx))) + c2 * dlib::pointwise_multiply(s, (G_best - dlib::colm(X, idx))));
            }
            limit_check(V, v_lim);
        }   // end of update_v


// ----------------------------------------------------------------------------------------

        void update_X(dlib::matrix<double> &X, std::vector<std::pair<double, double>> x_lim)
        {
            for (uint64_t idx = 0; idx < N; ++idx)
            {
                dlib::set_colm(X, idx) = (dlib::colm(X, idx) + dlib::colm(V, idx));
            }
            limit_check(X, x_lim);
        }   // end of update_X


// ----------------------------------------------------------------------------------------

	private:
	
		double c1, c2;
		double k;
		uint64_t N;			// number of members in the population
		uint64_t p;			// number of parameters in a population member
		uint64_t itr;		// number of iterations to perform
		
        //std::vector<dlib::matrix<double>> X;		// X is the parameter vector that will be optimized; V is the velocity vector
        dlib::matrix<double> V;		            // X is the parameter vector that will be optimized; V is the velocity vector

        dlib::matrix<double> P;	                // this matrix stores the population results for each member and each iteration
        double G;                               // this variable holds the best value from the function

        dlib::matrix<double> P_best;            // this matrix stores the best parameters for the current iteration
		dlib::matrix<double> G_best;	        // this matrix hold the best parameters for all of the current and past iterations



		dlib::rand rnd;
		
	
        void limit_check(dlib::matrix<double> &in, std::vector<std::pair<double, double>> lim)
        {
            for (uint64_t idx = 0; idx < in.nr(); ++idx)
            {
                for (uint64_t jdx = 0; jdx < in.nc(); ++jdx)
                {
                    in(idx, jdx) = std::max(std::min(lim[idx].second, in(idx, jdx)), lim[idx].first);

                }
            }
        }

		// void eval_population()
		// {
			
			
		// }	// end of eval_population
	


};	// end of class


#endif	// PSO_H
