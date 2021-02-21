using System;
using System.Linq;
using cAlgo.API;
using cAlgo.API.Indicators;
using cAlgo.API.Internals;
using cAlgo.Indicators;

namespace cAlgo
{
    [Robot(TimeZone = TimeZones.UTC, AccessRights = AccessRights.None)]
    public class TrendViaLRF : Robot
    {
        [Parameter]
        public DataSeries Source { get; set; }

        [Parameter(DefaultValue = 9)]
        public int PeriodFast { get; set; }

        [Parameter(DefaultValue = 90)]
        public int PeriodSlow { get; set; }

        private LinearRegressionForecast LRFFast;
        private LinearRegressionForecast LRFSlow;
        private string label = "TrendViaLRF";
        protected override void OnStart()
        {
            LRFFast = Indicators.LinearRegressionForecast(Source, PeriodFast);
            LRFSlow = Indicators.LinearRegressionForecast(Source, PeriodSlow);
        }

        protected override void OnTick()
        {
            var p = Positions.FindAll(label, Symbol);
            bool flat = false;
            if(p!= null)
            {
                flat = p.Length == 0 ? true : false;
            }
            
            if (flat)
            {
                CheckForEntry();
            }
            else
            {
                CheckForExit();
            }
        }

        private void CheckForEntry()
        {
            var fastValue = LRFFast.Result.LastValue;
            var slowValue = LRFSlow.Result.LastValue;
            bool 
        }

        protected override void OnStop()
        {
            // Put your deinitialization logic here
        }
    }
}
