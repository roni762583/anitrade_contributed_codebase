// this takes a data series and multiplies by a constant

using cAlgo.API;
using cAlgo.API.Internals;
using cAlgo.API.Indicators;
using cAlgo.Indicators;
using System;

namespace cAlgo
{
    [Levels(0.0)]
    [Indicator(IsOverlay = false, TimeZone = TimeZones.UTC, AutoRescale = false, AccessRights = AccessRights.None)]
    public class RetracementFromLastInflection : Indicator
    {
        [Parameter("Source")]
        public DataSeries Source { get; set; }

        //[Parameter("MA Period", DefaultValue = 10)]
        //public int maPeriod { get; set; }

        [Parameter(DefaultValue = "")]
        public string description { get; set; }

        [Output("Result", Color = Colors.White)]
        public IndicatorDataSeries Result { get; set; }

        public int lastInf;
        public double lastInfVal;

        protected override void Initialize()
        {
            // ma = Indicators.MovingAverage(Source1, maPeriod, MovingAverageType.Simple);
        }

        public override void Calculate(int index)
        {
            var s0 = Source[index];
            var s1 = Source[index - 1];
            var s2 = Source[index - 2];

            if (s0 < s1 && s1 > s2)
            {
                lastInf = 1;
                lastInfVal = s1;
            }
            else if (s0 > s1 && s1 < s2)
            {
                lastInf = -1;
                lastInfVal = s1;
            }
            Result[index] = Source[index] - lastInfVal;
        }
    }
}
