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



namespace common_impl
{


        // Variables for the file sytem watcher to track the file trigger method
        static DateTime last_read = DateTime.MinValue;
        static FileSystemWatcher fsw;
        private string triggerFile = "Trigger";
        private string triggerFilePath = "..//..//";

        private void config_file_watcher(string filepath, string filter)
        {

            fsw = new FileSystemWatcher();
            fsw.Path = filepath;

            /* Watch for changes in LastAccess and LastWrite times, and the renaming of files or directories. */
            fsw.NotifyFilter = NotifyFilters.LastWrite; // | NotifyFilters.FileName | NotifyFilters.DirectoryName;

            // Only watch text files.
            fsw.Filter = filter;

            // Add event handlers.
            fsw.Changed += new FileSystemEventHandler(TriggerFileWatcherOnChange);

        }   // end of config_file_watcher


        private void enable_file_watcher(bool enable)
        {
            fsw.EnableRaisingEvents = enable;

        }   // end of enable_file_watcher


        private void file_watcher_change(object source, FileSystemEventArgs e)
        {

            enable_file_watcher(false);
            DateTime last_write_time = File.GetLastWriteTime(e.FullPath);

            if (last_write_time.Subtract(last_read).Ticks >= 10000)
            {
                FileStream fs = new FileStream(e.FullPath, FileMode.Open, FileAccess.Read, FileShare.ReadWrite);

                //using (StreamReader triggerFile = new StreamReader(fs))
                using (BinaryReader triggerFile = new BinaryReader(fs))
                {
                    triggerValue = triggerFile.Read();

                    triggerFile.Dispose();
                    fs.Close();

                    //if (triggerValue == 1)
                    //{
                    //    //msgConsole_RTB.AppendText("File Trigger..." + Environment.NewLine);
                    //    //msgConsole_RTB.ScrollToCaret();
                    //    //var p = new Main_GUI();
                    //    //p.Trigger_BTN_Click(null, null);
                    //    this.Trigger();
                    //    //Invoke(new Action(() => { Trigger(); }));
                    //}

                }
                last_read = last_write_time;

            }

            enable_file_watcher(true);

        }   // end of file_watcher_change
        
}