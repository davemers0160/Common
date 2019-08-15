// using System;
// using System.Windows.Forms;
// using System.IO;
// using System.Collections;
// using System.Collections.Generic;
// using System.ComponentModel;
// using System.Data;
// using System.Drawing;
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
using System.Windows.Forms.FileDialog

namespace common_impl
{

    //void select_file(object sender, EventArgs e)
    void select_file(string init_dir, string filter, ref string file_path, ref string file_name)
    {

        file_path = string.Empty;
        file_name = string.Empty;
        
        using(OpenFileDialog ofd = new OpenFileDialog())
        {
            ofd.InitialDirectory = init_dir;
            ofd.Filter = filter;
            ofd.RestoreDirectory  = false;

            //DialogResult result = ofd.ShowDialog();

            if (ofd.ShowDialog() == DialogResult.OK)
            {

                string fileName = ofd.FileName;

                file_name = ofd.SafeFileName;
                file_path = Path.GetDirectoryName(fileName) + "\\";

            }
        }
    }   // end of select_file
        
}   // end of namespace
        