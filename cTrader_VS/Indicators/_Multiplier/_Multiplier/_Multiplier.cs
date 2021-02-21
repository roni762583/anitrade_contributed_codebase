// this takes a data series and multiplies by a constant

using cAlgo.API;
using cAlgo.API.Internals;
using cAlgo.API.Indicators;
using cAlgo.Indicators;

namespace cAlgo
{
    [Indicator(IsOverlay = false, TimeZone = TimeZones.UTC, AutoRescale = false, AccessRights = AccessRights.None)]
    public class _Multiplier : Indicator
    {
        [Parameter("Source")]
        public DataSeries Source { get; set; }

        [Parameter(DefaultValue = 10000)]
        public double Coefficient { get; set; }

        [Parameter(DefaultValue = "")]
        public string description { get; set; }

        [Output("Result", Color = Colors.White)]
        public IndicatorDataSeries Result { get; set; }

        private IndicatorDataSeries result;

        protected override void Initialize()
        {
            //result = Source.
        }

        public override void Calculate(int index)
        {
            Result[index] = Source[index] * Coefficient;
        }
    }
}
