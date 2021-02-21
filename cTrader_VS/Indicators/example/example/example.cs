using System;
using cAlgo.API;
using cAlgo.API.Internals;
using cAlgo.API.Indicators;
using cAlgo.Indicators;

namespace cAlgo
{
    [Indicator(IsOverlay = false, TimeZone = TimeZones.UTC, AccessRights = AccessRights.None)]
    public class example : Indicator
    {
        [Parameter(DefaultValue = 0.0)]
        public double Parameter { get; set; }

        [Output("Main")]
        public IndicatorDataSeries Result { get; set; }


        protected override void Initialize()
        {
            // Initialize and create nested indicators
        }

        public override void Calculate(int index)
        {
            Print("b4 if, index=", index);
            if (index > 3)
            {
                Print("after if, index=", index);
                return;
            }
            // Calculate value at specified index
            // Result[index] = ...
        }
    }
}
