using System;
// using System.Windows.Forms;
using System.IO;
// using System.Collections;
// using System.Collections.Generic;
// using System.ComponentModel;
// using System.Data;
using System.Drawing;
// using System.Linq;
// using System.Text;
// using System.Threading;
// using System.Threading.Tasks;
// using Microsoft.Win32;
// using System.Runtime.InteropServices;
// using System.Windows.Forms.DataVisualization.Charting;
// using System.Numerics;
// using System.IO.Ports;
// using System.Diagnostics;


namespace common
{

    public class jet_colormap
    {

        private float jet_clamp(float v)
        {
            float t = v < 0.0f ? 0.0f : v;
            return t > 1.0f ? 1.0f : t;
        }

        public Color float_to_rgba_jet(float t, float t_min, float t_max)
        {
            float t_range = t_max - t_min;
            float t_avg = (t_max + t_min) / 2.0f;
            float t_m = (t_max - t_avg) / 2.0f;

            float r = jet_clamp(1.5f - Math.Abs((4 / t_range)*(t - t_avg - t_m)));
            float g = jet_clamp(1.5f - Math.Abs((4 / t_range)*(t - t_avg)));
            float b = jet_clamp(1.5f - Math.Abs((4 / t_range)*(t - t_avg + t_m)));

            return Color.FromArgb(255, (byte)(255 * r), (byte)(255 * g), (byte)(255 * b));
            
        }   // end of float_to_rgba_jet
        
    }   // end of class impl

}   // end of namespace common