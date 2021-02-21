// this takes a data series and multiplies by a constant

using cAlgo.API;
using cAlgo.API.Internals;
using cAlgo.API.Indicators;
using cAlgo.Indicators;

namespace cAlgo
{
    [Levels(0.0)]
    [Indicator(IsOverlay = false, TimeZone = TimeZones.UTC, AutoRescale = false, AccessRights = AccessRights.None)]
    public class _DTO : Indicator
    {
        [Parameter("Source1")]
        public DataSeries Source1 { get; set; }

        [Parameter("MA Period", DefaultValue = 10)]
        public int maPeriod { get; set; }

        [Parameter(DefaultValue = "")]
        public string description { get; set; }

        [Output("Result", Color = Colors.White)]
        public IndicatorDataSeries Result { get; set; }
        public MovingAverage ma;
        //private IndicatorDataSeries result;

        protected override void Initialize()
        {
            ma = Indicators.MovingAverage(Source1, maPeriod, MovingAverageType.Simple);
        }

        public override void Calculate(int index)
        {
            Result[index] = (Source1[index] - ma.Result[index]) / ma.Result[index];
        }
    }
}
