/* 
This code is a version of the OpenSimplex random noise generator which is a cousin of the Perlin Noise.

Ported from: https://gist.github.com/KdotJPG/b1270127455a94ac5d19
This is a C++ implementation of the Jave version presented above
This version only implements the 2-D versions because that's all I needed right now
The 3-D version may be implemented later
 
The octave version comes from the following:
https://flafla2.github.io/2014/08/09/perlinnoise.html

*/

#ifndef SIMPLEX_NOISE_H
#define SIMPLEX_NOISE_H

#include <cstdint>
#include <vector>
#include <algorithm>


class open_simplex_noise
{
private:
    const double STRETCH_CONSTANT_2D = -0.211324865405187;    //(1/Math.sqrt(2+1)-1)/2;
    const double SQUISH_CONSTANT_2D = 0.366025403784439;      //(Math.sqrt(2+1)-1)/2;
    const double STRETCH_CONSTANT_3D = -1.0 / 6;              //(1/Math.sqrt(3+1)-1)/3;
    const double SQUISH_CONSTANT_3D = 1.0 / 3;                //(Math.sqrt(3+1)-1)/3;
    const double STRETCH_CONSTANT_4D = -0.138196601125011;    //(1/Math.sqrt(4+1)-1)/4;
    const double SQUISH_CONSTANT_4D = 0.309016994374947;      //(Math.sqrt(4+1)-1)/4;

    const double NORM_CONSTANT_2D = 47;
    const double NORM_CONSTANT_3D = 103;
    const double NORM_CONSTANT_4D = 30;

    const long DEFAULT_SEED = 0;

    std::vector<int16_t> perm;

    //Gradients for 2D. They approximate the directions to the
    //vertices of an octagon from the center.
    std::vector<int8_t> gradients_2D =
    {
         5,  2,    2,  5,
        -5,  2,   -2,  5,
         5, -2,    2, -5,
        -5, -2,   -2, -5,
    };


    // ----------------------------------------------------------------------------------------
    double extrapolate(int32_t xsb, int32_t ysb, double dx, double dy)
    {
        int32_t index = perm[(perm[xsb & 0xFF] + ysb) & 0xFF] & 0x0E;
        return (gradients_2D[index] * dx + gradients_2D[index + 1] * dy);
    }

    // ----------------------------------------------------------------------------------------
    int32_t fast_floor(double x)
    {
        int32_t xi = (int32_t)x;
        return x < xi ? xi - 1 : xi;
    }

// ----------------------------------------------------------------------------------------
public:
    open_simplex_noise() = default;

    //Initializes the class using a permutation array generated from a 64-bit seed.
    //Generates a proper permutation (i.e. doesn't merely perform N successive pair swaps on a base array)
    //Uses a simple 64-bit LCG.
    open_simplex_noise(long seed)
    {
        init(seed);
    }

    // ----------------------------------------------------------------------------------------
    void init(long seed)
    {
        int32_t idx;

        perm.clear();
        perm.resize(256);

        //permGradIndex3D = new short[256];

        std::vector<int16_t> source(256);

        for (idx = 0; idx < 256; idx++)
        {
            source[idx] = idx;
        }

        seed = seed * 6364136223846793005L + 1442695040888963407L;
        seed = seed * 6364136223846793005L + 1442695040888963407L;
        seed = seed * 6364136223846793005L + 1442695040888963407L;

        for (idx = 255; idx >= 0; --idx)
        {
            seed = seed * 6364136223846793005L + 1442695040888963407L;
            int32_t r = (int32_t)((seed + 31) % (idx + 1));
            if (r < 0)
                r += (idx + 1);
            perm[idx] = source[r];
            //permGradIndex3D[i] = (short)((perm[i] % (gradients3D.Length / 3)) * 3);
            source[r] = source[idx];
        }

    }   // end of init

    // ----------------------------------------------------------------------------------------

    //2D OpenSimplex (Simplectic) Noise.
    double evaluate(double x, double y)
    {
        //Place input coordinates onto grid.
        double stretch_offset = (x + y) * STRETCH_CONSTANT_2D;
        double xs = x + stretch_offset;
        double ys = y + stretch_offset;

        //Floor to get grid coordinates of rhombus (stretched square) super-cell origin.
        int xsb = fast_floor(xs);
        int ysb = fast_floor(ys);

        //Skew out to get actual coordinates of rhombus origin. We'll need these later.
        double squish_offset = (xsb + ysb) * SQUISH_CONSTANT_2D;
        double xb = xsb + squish_offset;
        double yb = ysb + squish_offset;

        //Compute grid coordinates relative to rhombus origin.
        double xins = xs - xsb;
        double yins = ys - ysb;

        //Sum those together to get a value that determines which region we're in.
        double in_sum = xins + yins;

        //Positions relative to origin point.
        double dx0 = x - xb;
        double dy0 = y - yb;

        //We'll be defining these inside the next block and using them afterwards.
        double dx_ext, dy_ext;
        int xsv_ext, ysv_ext;

        double value = 0;

        //Contribution (1,0)
        double dx1 = dx0 - 1 - SQUISH_CONSTANT_2D;
        double dy1 = dy0 - 0 - SQUISH_CONSTANT_2D;
        double attn1 = 2 - dx1 * dx1 - dy1 * dy1;
        if (attn1 > 0)
        {
            attn1 *= attn1;
            value += attn1 * attn1 * extrapolate(xsb + 1, ysb + 0, dx1, dy1);
        }

        //Contribution (0,1)
        double dx2 = dx0 - 0 - SQUISH_CONSTANT_2D;
        double dy2 = dy0 - 1 - SQUISH_CONSTANT_2D;
        double attn2 = 2 - dx2 * dx2 - dy2 * dy2;
        if (attn2 > 0)
        {
            attn2 *= attn2;
            value += attn2 * attn2 * extrapolate(xsb + 0, ysb + 1, dx2, dy2);
        }

        if (in_sum <= 1)
        { 
            //We're inside the triangle (2-Simplex) at (0,0)
            double zins = 1 - in_sum;
            if (zins > xins || zins > yins)
            { 
                //(0,0) is one of the closest two triangular vertices
                if (xins > yins)
                {
                    xsv_ext = xsb + 1;
                    ysv_ext = ysb - 1;
                    dx_ext = dx0 - 1;
                    dy_ext = dy0 + 1;
                }
                else
                {
                    xsv_ext = xsb - 1;
                    ysv_ext = ysb + 1;
                    dx_ext = dx0 + 1;
                    dy_ext = dy0 - 1;
                }
            }
            else
            { 
                //(1,0) and (0,1) are the closest two vertices.
                xsv_ext = xsb + 1;
                ysv_ext = ysb + 1;
                dx_ext = dx0 - 1 - 2 * SQUISH_CONSTANT_2D;
                dy_ext = dy0 - 1 - 2 * SQUISH_CONSTANT_2D;
            }
        }
        else
        { 
            //We're inside the triangle (2-Simplex) at (1,1)
            double zins = 2 - in_sum;

            if (zins < xins || zins < yins)
            { 
                //(0,0) is one of the closest two triangular vertices
                if (xins > yins)
                {
                    xsv_ext = xsb + 2;
                    ysv_ext = ysb + 0;
                    dx_ext = dx0 - 2 - 2 * SQUISH_CONSTANT_2D;
                    dy_ext = dy0 + 0 - 2 * SQUISH_CONSTANT_2D;
                }
                else
                {
                    xsv_ext = xsb + 0;
                    ysv_ext = ysb + 2;
                    dx_ext = dx0 + 0 - 2 * SQUISH_CONSTANT_2D;
                    dy_ext = dy0 - 2 - 2 * SQUISH_CONSTANT_2D;
                }
            }
            else
            { 
                //(1,0) and (0,1) are the closest two vertices.
                dx_ext = dx0;
                dy_ext = dy0;
                xsv_ext = xsb;
                ysv_ext = ysb;
            }

            xsb += 1;
            ysb += 1;
            dx0 = dx0 - 1 - 2 * SQUISH_CONSTANT_2D;
            dy0 = dy0 - 1 - 2 * SQUISH_CONSTANT_2D;
        }

        //Contribution (0,0) or (1,1)
        double attn0 = 2 - dx0 * dx0 - dy0 * dy0;
        if (attn0 > 0)
        {
            attn0 *= attn0;
            value += attn0 * attn0 * extrapolate(xsb, ysb, dx0, dy0);
        }

        //Extra Vertex
        double attn_ext = 2 - dx_ext * dx_ext - dy_ext * dy_ext;
        if (attn_ext > 0)
        {
            attn_ext *= attn_ext;
            value += attn_ext * attn_ext * extrapolate(xsv_ext, ysv_ext, dx_ext, dy_ext);
        }

        return value / NORM_CONSTANT_2D;

    }   // end of evaluate

    double octave(double x, double y, uint32_t octaves, double persistence) 
    {
        uint32_t idx;
        double total = 0;
        double frequency = 1;
        double amplitude = 1;
        double max_value = 0;  // Used for normalizing result to 0.0 - 1.0

        for (idx = 0; idx < octaves; ++idx) 
        {
            total += evaluate(x * frequency, y * frequency) * amplitude;

            max_value += amplitude;

            amplitude *= persistence;
            frequency *= 2;
        }

        return total / max_value;

    }   // end of octave

};

#endif	// SIMPLEX_NOISE_H
