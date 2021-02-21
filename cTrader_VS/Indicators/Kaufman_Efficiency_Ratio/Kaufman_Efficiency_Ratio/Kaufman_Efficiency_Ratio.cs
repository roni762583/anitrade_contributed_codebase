using System;
using cAlgo.API;
using cAlgo.API.Internals;
using cAlgo.API.Indicators;
using cAlgo.Indicators;

namespace cAlgo
{
    [Indicator(IsOverlay = false, TimeZone = TimeZones.UTC, AccessRights = AccessRights.None)]
    public class Kaufman_Efficiency_Ratio : Indicator
    {
        [Parameter("LookBack", DefaultValue = 5)]
        public int n { get; set; }

        [Output("ER")]
        public IndicatorDataSeries ER { get; set; }


        protected override void Initialize()
        {
            // Initialize and create nested indicators
        }

        public override void Calculate(int index)
        {
            // Calculate value at specified index
            int idx = MarketSeries.Close.Count - 1;
            double close = MarketSeries.Close[idx];
            double close1 = MarketSeries.Close[idx - 1];
            double closen = MarketSeries.Close[idx - n];
            ER[index] = Math.Abs(close - closen) / (n * GetSumChg(idx));
        }

        public double GetSumChg(int idx)
        {
            double sum = 0.0;
            for (int i = idx - n; i <= idx; i++)
            {
                sum += Math.Abs(MarketSeries.Close[i] - MarketSeries.Close[i-1]);
            }
            return sum;
        }
    }
}
