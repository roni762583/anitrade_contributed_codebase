using System;
using cAlgo.API;
using cAlgo.API.Internals;
using cAlgo.API.Indicators;
using cAlgo.Indicators;

namespace cAlgo
{
    [Indicator(IsOverlay = true, TimeZone = TimeZones.UTC, AccessRights = AccessRights.None)]
    public class VWAPappx : Indicator
    {
        [Parameter(DefaultValue = 500)]
        public int VWAP_Bars { get; set; }

        [Output("Main", Color = Colors.White)]
        public IndicatorDataSeries Result { get; set; }

        private IndicatorDataSeries tpvSum;
        //typical price * tick volume, sum
        private IndicatorDataSeries vSum;
        //sum of tick volume
        protected override void Initialize()
        {
            tpvSum = CreateDataSeries();
            vSum = CreateDataSeries();
        }

        public override void Calculate(int index)
        {
            //tpv calc.
            int i = index;
            int n = VWAP_Bars;
            double xi = MarketSeries.Typical[i] * MarketSeries.TickVolume[i];
            //prime the initial series values
            if (i < n)
            {
                tpvSum[index] = xi;
            }
            else
            {
                double xin = MarketSeries.Typical[i - n] * MarketSeries.TickVolume[i - n];
                tpvSum[index] = tpvSum[i - 1] + xi - xin;
            }

            //v calc.
            xi = MarketSeries.TickVolume[i];
            //prime the initial series values
            if (i < n)
            {
                vSum[index] = xi;
            }
            else
            {
                double xin = MarketSeries.TickVolume[i - n];
                vSum[index] = vSum[i - 1] + xi - xin;
            }

            //prevent divide by zero
            Result[index] = tpvSum[i] / (vSum[i] == 0 ? 1 : vSum[i]);
        }
    }
}
