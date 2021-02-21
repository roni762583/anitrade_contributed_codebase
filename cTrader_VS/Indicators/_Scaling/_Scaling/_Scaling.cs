// indicator for linear feature scaling of data series

using System;
using cAlgo.API;
using cAlgo.API.Internals;
using cAlgo.API.Indicators;
using cAlgo.Indicators;

namespace cAlgo
{
    [Indicator(TimeZone = TimeZones.UTC, AccessRights = AccessRights.None)]
    public class _Scaling : Indicator
    {
        [Parameter("Source")]
        public DataSeries Source { get; set; }

        [Parameter(DefaultValue = 1000, MinValue = 0)]
        //0 means entire data series
        public int lookBack { get; set; }

        [Parameter(DefaultValue = 0.0)]
        public double scaledMin { get; set; }

        [Parameter(DefaultValue = 1.0)]
        public double scaledMax { get; set; }

        [Parameter(DefaultValue = "")]
        public string description { get; set; }

        [Output("Result", Color = Colors.White)]
        public IndicatorDataSeries Result { get; set; }

        protected override void Initialize()
        {

        }

        public override void Calculate(int index)
        {
            var lb = lookBack == 0 ? Source.Count : lookBack;
            //get look back period
            var dataMin = Source.Minimum(lb);
            var dataMax = Source.Maximum(lb);
            //var dataRange = dataMax - dataMin;
            //var delta = Source[index] - dataMin;
            var scale = (Source[index] - dataMin) / (dataMax - dataMin);
            Result[index] = scaledMin * (1 - scale) + scaledMax * scale;
        }
    }
}
