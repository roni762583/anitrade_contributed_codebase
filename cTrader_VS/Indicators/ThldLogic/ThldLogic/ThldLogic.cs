// compares data series to Threshold, outputs digital logic +1 for above, -1 for below

using cAlgo.API;
using cAlgo.API.Internals;
using cAlgo.API.Indicators;
using cAlgo.Indicators;

namespace cAlgo
{
    [Indicator(IsOverlay = false, TimeZone = TimeZones.UTC, AutoRescale = false, AccessRights = AccessRights.None)]
    public class ThldLogic : Indicator
    {
        [Parameter("Source")]
        public DataSeries Source { get; set; }

        [Parameter("Threshold", DefaultValue = 0.0)]
        public double thld { get; set; }

        [Parameter(DefaultValue = "")]
        public string description { get; set; }

        [Output("Result", Color = Colors.White, IsHistogram = true)]
        public IndicatorDataSeries Result { get; set; }

        protected override void Initialize()
        {
            //result = Source.
        }

        public override void Calculate(int index)
        {
            Result[index] = Source[index] > 0 ? 1 : -1;
        }
    }
}
