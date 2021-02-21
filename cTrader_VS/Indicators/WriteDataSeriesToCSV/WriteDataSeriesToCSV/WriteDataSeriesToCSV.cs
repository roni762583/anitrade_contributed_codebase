using cAlgo.API;
using cAlgo.API.Internals;
using cAlgo.API.Indicators;
using cAlgo.Indicators;
using System.IO;
using System;
using System.Windows.Forms;
using System.Threading;

namespace cAlgo
{
    [Levels(0.0)]
    [Indicator(ScalePrecision = 10, IsOverlay = false, TimeZone = TimeZones.UTC, AutoRescale = false, AccessRights = AccessRights.FullAccess)]
    public class WriteDataSeriesToCSV : Indicator
    {
        [Parameter("Source1")]
        public DataSeries Source1 { get; set; }
        [Parameter("Column Heading Source 1", DefaultValue = "col1")]
        public string col1name { get; set; }

        [Parameter("Source2")]
        public DataSeries Source2 { get; set; }
        [Parameter("Column Heading Source 2", DefaultValue = "col2")]
        public string col2name { get; set; }

        [Parameter("Source3")]
        public DataSeries Source3 { get; set; }
        [Parameter("Column Heading Source 3", DefaultValue = "col3")]
        public string col3name { get; set; }

        [Parameter("Source4")]
        public DataSeries Source4 { get; set; }
        [Parameter("Column Heading Source 4", DefaultValue = "col4")]
        public string col4name { get; set; }


        [Parameter("file name", DefaultValue = "myDataFile.txt")]
        public string fileName { get; set; }

        [Parameter("Select to write", DefaultValue = false)]
        public bool write { get; set; }

        [Output("Result", Color = Colors.White)]
        public IndicatorDataSeries Result { get; set; }

        //private IndicatorDataSeries result;

        protected override void Initialize()
        {
            //DialogResult result1 = DialogResult.Retry;
            //result1 = MessageBox.Show("Enter parameters, then press 'OK'", "WriteDataSeriesToCSV", MessageBoxButtons.OK);
            //while (result1!=DialogResult.OK)
            //{
            //    //Sleep(1000);
            //}
            if (write)
                Write();
            Result = CreateDataSeries();
        }

        //writes to file
        public void Write()
        {
            var desktopFolder = Environment.GetFolderPath(Environment.SpecialFolder.DesktopDirectory);
            var filePath = Path.Combine(desktopFolder, fileName);

            //StreamWriter
            using (var sw = File.AppendText(filePath))
            {
                sw.AutoFlush = true;
                //file will be saved on each change
                var ln = string.Format("{0},{1},{2},{3}", col1name, col2name, col3name, col4name);

                sw.WriteLine(ln);
                //write column names
                for (int i = 0; i < Source1.Count; i++)
                {
                    var c1 = Source1[i].ToString();
                    var c2 = Source2[i].ToString();
                    var c3 = Source3[i].ToString();
                    var c4 = Source4[i].ToString();
                    ln = string.Format("{0},{1},{2},{3}", c1, c2, c3, c4);
                    sw.WriteLine(ln);
                }
                sw.Close();
            }
        }

        public override void Calculate(int index)
        {
        }
    }
}

