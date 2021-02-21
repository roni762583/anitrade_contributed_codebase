using System;
using cAlgo.API;
using cAlgo.API.Internals;
using cAlgo.API.Indicators;
using cAlgo.Indicators;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace cAlgo
{
    [Indicator(IsOverlay = false, TimeZone = TimeZones.UTC, AccessRights = AccessRights.None, ScalePrecision = 15)]
    public class LRFMAnormThld : Indicator
    {
        [Parameter()]
        public DataSeries Source { get; set; }

        [Parameter(DefaultValue = 100)]
        public int LRFperiod { get; set; }

        [Parameter(DefaultValue = 14)]
        public int MAperiod { get; set; }

        [Parameter(DefaultValue = 500)]
        public int ZSperiod { get; set; }

        [Parameter(DefaultValue = 0.75)]
        public double HiThld { get; set; }

        [Parameter(DefaultValue = -0.75)]
        public double LoThld { get; set; }

        [Output("Main", Color = Colors.White, PlotType = PlotType.Histogram)]
        public IndicatorDataSeries Result { get; set; }
        [Output("two", Color = Colors.Red)]
        public IndicatorDataSeries Result2 { get; set; }

        private LinearRegressionForecast lrf;
        private MovingAverage ma;
        private IndicatorDataSeries diff;
        private TimeSeriesMovingAverage zsma;
        private StandardDeviation zsstddev;

        protected override void Initialize()
        {
            lrf = Indicators.LinearRegressionForecast(Source, LRFperiod);
            ma = Indicators.SimpleMovingAverage(lrf.Result, MAperiod);
            //diff = Indicators.GetIndicator<_Difference>(lrf.Result, ma.Result);
            //for (int i = 0; i < lrf.Result.Count; i++)
            //{
            //    diff.Result[i] = lrf.Result[i] - ma.Result[i];
            //}
            diff = CreateDataSeries();
            zsma = Indicators.TimeSeriesMovingAverage(diff, ZSperiod);
            zsstddev = Indicators.StandardDeviation(diff, ZSperiod, MovingAverageType.Simple);
        }

        public override void Calculate(int index)
        {
            var sma = ma.Result[index];
            var slrf = lrf.Result[index];
            diff[index] = slrf - sma;
            var ind = (diff[index] - zsma.Result[index]) / zsstddev.Result[index];
            Result[index] = ind >= HiThld ? 1.0 : (ind <= LoThld ? -1.0 : 0);
            Result2[index] = ind;
        }
    }
}
