using System;
// using System.Windows.Forms;
using System.IO;
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


namespace common
{

    public class file_watcher
    {
        // Variables for the file sytem watcher
        DateTime last_read = DateTime.MinValue;
        DateTime last_write_time = DateTime.MinValue;
        FileSystemWatcher fsw;
        public bool changed = true;

        //private string triggerFile = "Trigger";
        //private string triggerFilePath = "..//..//";

        public void config_file_watcher(string file_path, string file_name)
        {
            
            fsw = new FileSystemWatcher();
            fsw.Path = Path.GetDirectoryName(file_path);

            // Watch for changes in LastAccess and LastWrite times, and the renaming of files or directories
            fsw.NotifyFilter = NotifyFilters.LastWrite; // | NotifyFilters.FileName | NotifyFilters.DirectoryName;

            // Only watch text files.
            fsw.Filter = file_name;

            // Add event handlers.
            fsw.Changed += new FileSystemEventHandler(file_watcher_change);

        }   // end of config_file_watcher


        public void enable_file_watcher(bool enable)
        {
            fsw.EnableRaisingEvents = enable;
        }   // end of enable_file_watcher


        public void file_watcher_change(object source, FileSystemEventArgs e)
        {

            enable_file_watcher(false);
            DateTime last_write_time = File.GetLastWriteTime(e.FullPath);

            if (last_write_time.Subtract(last_read).Ticks >= 10000)
            {
                changed = true;
                //mnist_app.Form1.img.Clear();
                //mnist_app.Form1.img = mnist_app.Form1.load_image(mnist_app.Form1.image_file_path);
                last_read = last_write_time;

            }

            enable_file_watcher(true);

        }   // end of file_watcher_change

    }   // end of class impl

}   // end of namespace common
