using System;
using System.Windows.Forms;
using System.IO;
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Win32;
using System.Runtime.InteropServices;
using System.Windows.Forms.DataVisualization.Charting;
using System.Numerics;
using System.IO.Ports;
using System.Diagnostics;



namespace common_impl
{




        private void configTriggerWatcher(string filepath, string filter)
        {

            triggerWatcher = new FileSystemWatcher();
            triggerWatcher.Path = filepath;

            /* Watch for changes in LastAccess and LastWrite times, and the renaming of files or directories. */
            triggerWatcher.NotifyFilter = NotifyFilters.LastWrite; // | NotifyFilters.FileName | NotifyFilters.DirectoryName;

            // Only watch text files.
            triggerWatcher.Filter = filter;

            // Add event handlers.
            triggerWatcher.Changed += new FileSystemEventHandler(TriggerFileWatcherOnChange);

        }   // end of configTriggerWatcher


        private void enableTriggerWatcher(bool enable)
        {
            triggerWatcher.EnableRaisingEvents = enable;

        }   // end of enableTriggerWatcher


        private void TriggerFileWatcherOnChange(object source, FileSystemEventArgs e)
        {

            enableTriggerWatcher(false);
            DateTime lastWriteTime = File.GetLastWriteTime(e.FullPath);

            if (lastWriteTime.Subtract(lastRead).Ticks >= 10000)
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
                lastRead = lastWriteTime;

            }

            enableTriggerWatcher(true);

        }   // end of OnChanged
        
}