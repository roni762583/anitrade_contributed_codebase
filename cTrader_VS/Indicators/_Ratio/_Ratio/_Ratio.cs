// this takes a data series and multiplies by a constant

using cAlgo.API;
using cAlgo.API.Internals;
using cAlgo.API.Indicators;
using cAlgo.Indicators;

namespace cAlgo
{
    [Levels(-1, 0, 1)]
    [Indicator(IsOverlay = false, TimeZone = TimeZones.UTC, AutoRescale = false, AccessRights = AccessRights.None)]
    public class _Ratio : Indicator
    {
        [Parameter("Source1")]
        public DataSeries Source1 { get; set; }

        [Parameter("Source2")]
        public DataSeries Source2 { get; set; }

        [Parameter(DefaultValue = "")]
        public string description { get; set; }

        [Output("Result", Color = Colors.White)]
        public IndicatorDataSeries Result { get; set; }

        private IndicatorDataSeries result;

        protected override void Initialize()
        {
        }

        public override void Calculate(int index)
        {
            Result[index] = Source1[index] / Source2[index];
        }
    }
}
