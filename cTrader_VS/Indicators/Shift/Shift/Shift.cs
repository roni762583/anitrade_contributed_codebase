// shifts data series by index

using cAlgo.API;
using cAlgo.API.Internals;
using cAlgo.API.Indicators;
using cAlgo.Indicators;

namespace cAlgo
{
    [Indicator(IsOverlay = false, TimeZone = TimeZones.UTC, AutoRescale = false, AccessRights = AccessRights.None)]
    public class Shift : Indicator
    {
        [Parameter("Source")]
        public DataSeries Source { get; set; }

        [Parameter("index shift", DefaultValue = -1)]
        public int shft { get; set; }

        [Parameter(DefaultValue = "")]
        public string description { get; set; }

        [Output("Result", Color = Colors.White)]
        public IndicatorDataSeries Result { get; set; }

        protected override void Initialize()
        {
            //result = Source.
        }

        public override void Calculate(int index)
        {
            Result[index] = Source[index + shft];
        }
    }
}
