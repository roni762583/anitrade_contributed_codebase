// to indicate time series breaking through Bollinger bands regarded only when Band Gap is significant

using System;
using cAlgo.API;
using cAlgo.API.Internals;
using cAlgo.API.Indicators;
using cAlgo.Indicators;

namespace cAlgo
{
    [Levels(1.0, 0, -1.0)]
    [Indicator(TimeZone = TimeZones.UTC, AccessRights = AccessRights.None)]
    public class BollingerBandsSignal : Indicator
    {
        [Parameter(DefaultValue = 1000)]
        public int lookBack { get; set; }

        [Parameter("Data Series")]
        public DataSeries source { get; set; }

        [Parameter(DefaultValue = 20)]
        public int bandsPeriod { get; set; }

        [Parameter(DefaultValue = 2.0)]
        public double deviations { get; set; }

        [Parameter(DefaultValue = MovingAverageType.Simple)]
        public MovingAverageType bandsMAType { get; set; }

        [Parameter(DefaultValue = 0.99)]
        public double highPctBThld { get; set; }

        [Parameter(DefaultValue = 0.01)]
        public double lowPctBThld { get; set; }

        [Parameter(DefaultValue = 1.4)]
        public double minBandGapZscore { get; set; }

        [Output("Signal", Color = Colors.White)]
        public IndicatorDataSeries Signal { get; set; }

        private BollingerBands bb;
        private IndicatorDataSeries pctB;
        private IndicatorDataSeries bandsGap;
        //private ZScore zscore;
        private MovingAverage ma;
        private StandardDeviation sd;

        protected override void Initialize()
        {

            bb = Indicators.BollingerBands(source, bandsPeriod, deviations, bandsMAType);
            pctB = CreateDataSeries();
            bandsGap = CreateDataSeries();
            // zscore = Indicators.GetIndicator<ZScore>(bandsGap, lookBack);
            ma = Indicators.MovingAverage(bandsGap, lookBack, MovingAverageType.Simple);
            sd = Indicators.StandardDeviation(bandsGap, lookBack, MovingAverageType.Simple);
        }

        public override void Calculate(int index)
        {

            // %B = (series-lowerband) / (upperBand - lowerband)
            pctB[index] = (source[index] - bb.Bottom[index]) / (bb.Top[index] - bb.Bottom[index]);

            bandsGap[index] = bb.Top[index] - bb.Bottom[index];

            double zs = (bandsGap[index] - ma.Result.LastValue) / sd.Result.LastValue;
            bool hpb = pctB[index] >= highPctBThld;
            // high pct b over thld?
            bool lpb = pctB[index] <= lowPctBThld;
            // low pct b over thld?
            bool mbg = zs >= minBandGapZscore;
            // minimum bands gap met?
            //if (mbg)
            //{
            //    Signal[index] = hpb ? 1.0 : 0;
            //    Signal[index] = lpb ? -1.0 : 0;
            //}
            Signal[index] = mbg ? (hpb ? 1 : (lpb ? -1 : 0)) : 0;
        }
    }
}
