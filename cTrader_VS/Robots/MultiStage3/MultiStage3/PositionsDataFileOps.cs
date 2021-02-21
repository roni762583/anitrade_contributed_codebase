using System;
using System.Collections.Generic;
using System.Text;
using System.Linq;
using cAlgo.API;
using cAlgo.API.Indicators;
using cAlgo.API.Internals;
using cAlgo.Indicators;
using System.Threading;
using System.Data;
using System.IO;
using cAlgo;
using System.Globalization;


namespace cAlgo
{
    class PositionsDataFileOps
    {
        //this class to encapsulate methods used in managing data files for positions table

        //props
        public string label { get; set; }
        internal DataOps dataOps;
        internal PositionsDataTableOps dto;

        //fields
        public string dirPath; //path of directory 
        string fileName;//name of file w/o path
        public string filePath;//full path to positions data file

        //c'tor
        public PositionsDataFileOps(DataOps dataOps, PositionsDataTableOps dto)
        {
            this.dataOps = dataOps;
            this.dto = dto;
            this.label = dataOps.cBot.Label; //used for building path for data files

            //build directory and file paths
            string desktopFolder = Environment.GetFolderPath(Environment.SpecialFolder.DesktopDirectory);
            string dir = label + "_data";
            dirPath = Path.Combine(desktopFolder, dir);
            fileName = label + "_" + dataOps.cBot.Symbol.Code + ".dat";
            filePath = Path.Combine(dirPath, fileName);

            //check for existance of directory, create if none
            if (!Directory.Exists(dirPath)) Directory.CreateDirectory(dirPath);

            //if there is not file, make an empty one to allow program to run
            if (!File.Exists(filePath))
            {
                WriteDataTableToCSV(dto.BuildDataTableSchema(), filePath, ',');
            }
        }

        //methods        
        public void DataFileProcessor(DataTable dt)
        {
            //backs up old copy, re-writes dataTable as CSV, and cleans up old back ups
            
            //backs up old copy
            BackUpOldFile(filePath);

            //writes 
            WriteDataTableToCSV(dt, filePath,',');

            //cleans up back ups older than number of hours specified in param.
            CleanOldFiles(dirPath, 24);
        }

        private void WriteDataTableToCSV(DataTable dataTable, string filePath, char separator)
        {
            //writes dataTable as CSV
            //from Sumon Banerjee on: http://stackoverflow.com/questions/4959722/c-sharp-datatable-to-csv
            
            // Create the CSV file to which grid data will be exported.
            StreamWriter sw = new StreamWriter(filePath, false);
            int iColCount = dataTable.Columns.Count;
            for (int i = 0; i < iColCount; i++)
            {
                sw.Write(dataTable.Columns[i]);
                if (i < iColCount - 1)
                {
                    sw.Write(separator);
                }
            }
            sw.Write(sw.NewLine);
            // Now write all the rows.
            foreach (DataRow dr in dataTable.Rows)
            {
                for (int i = 0; i < iColCount; i++)
                {
                    if (!Convert.IsDBNull(dr[i]))
                    {
                        sw.Write(dr[i].ToString());
                    }
                    if (i < iColCount - 1)
                    {
                        sw.Write(separator);
                    }
                }
                sw.Write(sw.NewLine);
            }
            sw.Close();

        }

        internal string GetBakFilePath()
        {
            //file path for back up copies before re-write (re-name old file to...)
            string bakFileName = GetTimeStampString()+ fileName;
            return Path.Combine(dirPath, bakFileName);
        }//GetBakFilePath()

        internal string GetTimeStampString()
        {
            var YYYY = dataOps.cBot.Server.Time.Year.ToString();
            var MM = dataOps.cBot.Server.Time.Month.ToString();
            var DD = dataOps.cBot.Server.Time.Day.ToString();
            var hh = dataOps.cBot.Server.Time.Hour.ToString();
            var mm = dataOps.cBot.Server.Time.Minute.ToString();
            var ss = dataOps.cBot.Server.Time.Second.ToString();
            var ms = ((double)dataOps.cBot.Server.Time.Millisecond/1000).ToString().Split('.')[1];
            return YYYY + MM + DD + hh + mm + ss + "." + ms;
        }

        internal void CleanOldFiles(string dirPath, int hrs)
        {
            //loop over files in directory
            var oldFiles = new DirectoryInfo(dirPath).GetFiles().Where(file => file.CreationTime < DateTime.Now.AddHours(-hrs));
            foreach (var fi in oldFiles)
            {
                fi.Delete();
            }
        }//CleanOldFiles()

        internal void BackUpOldFile(string filePath)
        {
            if (File.Exists(filePath))
            {
                File.Copy(filePath, GetBakFilePath(), true);
                File.Delete(filePath);
            }
        }//BackUpOldFile()

    }//class
}//namespace
