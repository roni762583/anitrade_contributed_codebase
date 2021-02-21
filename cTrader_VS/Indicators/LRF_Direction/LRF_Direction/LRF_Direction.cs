using System;
using cAlgo.API;
using cAlgo.API.Internals;
using cAlgo.API.Indicators;
using cAlgo.Indicators;

namespace cAlgo
{
    [Indicator(IsOverlay = false, TimeZone = TimeZones.UTC, AccessRights = AccessRights.None)]
    public class LRF_Direction : Indicator
    {
        [Parameter()]
        public DataSeries Source { get; set; }

        [Parameter(DefaultValue = 50)]
        public int Period { get; set; }

        [Parameter(DefaultValue = 5)]
        public int Lag { get; set; }

        [Output("Main", Color = Colors.White, PlotType = PlotType.Histogram)]
        public IndicatorDataSeries Result { get; set; }

        private LinearRegressionForecast lrf;
        private TimeSeriesMovingAverage ma;
        private IndicatorDataSeries digital;
        protected override void Initialize()
        {
            lrf = Indicators.LinearRegressionForecast(Source, Period);
            digital = CreateDataSeries();
            ma = Indicators.TimeSeriesMovingAverage(digital, Lag);

        }

        public override void Calculate(int index)
        {


            var current = lrf.Result.IsRising() ? 1.0 : lrf.Result.IsFalling() ? -1.0 : 0;
            digital[index] = current;
            Result[index] = digital.Maximum(Lag) == digital.Minimum(Lag) ? current : Result[index - 1];
        }

        private bool RecentlySwitched()
        {
            return lrf.Result.Maximum(Lag) == lrf.Result.Minimum(Lag) ? true : false;
            //int lastBarIndex = lrf.Result.Count - 1;
            //int lagBarIndex = lastBarIndex - Lag;
            //var val = lrf.Result[lagBarIndex];

            //for (int i = lagBarIndex; i <= lastBarIndex; i++)
            //{
            //    if (lrf.Result[i] != val) return true;
            //}
        }
    }
}
