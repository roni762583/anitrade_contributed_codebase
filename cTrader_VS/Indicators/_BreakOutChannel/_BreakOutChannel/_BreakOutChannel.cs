// this takes a data series and multiplies by a constant

using cAlgo.API;
using cAlgo.API.Internals;
using cAlgo.API.Indicators;
using cAlgo.Indicators;

namespace cAlgo
{
    [Levels(-1.0, 0.0, 1.0)]
    [Indicator(IsOverlay = false, TimeZone = TimeZones.UTC, AutoRescale = false, AccessRights = AccessRights.None)]
    public class _BreakOutChannel : Indicator
    {
        [Parameter("Source")]
        public DataSeries Source { get; set; }

        [Parameter(DefaultValue = 2)]
        public int LookBack { get; set; }

        [Parameter(DefaultValue = "")]
        public string description { get; set; }

        [Output("Result", Color = Colors.White)]
        public IndicatorDataSeries Result { get; set; }

        //private IndicatorDataSeries result;
        private IndicatorDataSeries maximum;

        protected override void Initialize()
        {
            maximum = CreateDataSeries();
        }

        public override void Calculate(int index)
        {
            maximum[index] = Source.Maximum(LookBack);
            Result[index] = Source[index] > maximum[index - 1] ? 1.0 : 0.0;
        }
    }
}
