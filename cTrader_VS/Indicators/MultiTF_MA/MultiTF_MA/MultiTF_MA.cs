//modified GetIndexByDate() from ctdn example

using System;
using cAlgo.API;
using cAlgo.API.Internals;
using cAlgo.API.Indicators;

namespace cAlgo.Indicators
{
    [Indicator(IsOverlay = true, TimeZone = TimeZones.UTC)]
    public class MultiTF_MA : Indicator
    {
        [Parameter(DefaultValue = 5)]
        public int Period { get; set; }

        [Parameter("MA Type", DefaultValue = MovingAverageType.Exponential)]
        public MovingAverageType matyp { get; set; }

        [Parameter("TF1", DefaultValue = "Minute")]
        public TimeFrame TF1 { get; set; }

        [Parameter("TF2", DefaultValue = "Minute5")]
        public TimeFrame TF2 { get; set; }

        [Output("MA", Color = Colors.Red)]
        public IndicatorDataSeries MA { get; set; }

        [Output("MA TF1", Color = Colors.Yellow)]
        public IndicatorDataSeries MATF1 { get; set; }

        [Output("MA TF2", Color = Colors.Green)]
        public IndicatorDataSeries MATF2 { get; set; }

        private MarketSeries seriesTF1;
        private MarketSeries seriesTF2;

        private MovingAverage ma;
        private MovingAverage maTF1;
        private MovingAverage maTF2;

        protected override void Initialize()
        {
            Print("daily.toString()=", TimeFrame.Daily.ToString());
            seriesTF1 = MarketData.GetSeries(TF1);
            seriesTF2 = MarketData.GetSeries(TF2);

            ma = Indicators.MovingAverage(MarketSeries.Close, Period, matyp);
            maTF1 = Indicators.MovingAverage(seriesTF1.Close, Period, matyp);
            maTF2 = Indicators.MovingAverage(seriesTF2.Close, Period, matyp);
        }

        public override void Calculate(int index)
        {
            MA[index] = ma.Result[index];

            //var index5 = GetIndexByDate(series5, MarketSeries.OpenTime[index]);
            var index5 = GetIndexByTime(seriesTF1, MarketSeries.OpenTime[index]);
            if (index5 != -1)
                MATF1[index] = maTF1.Result[index5];

            //var index10 = GetIndexByDate(series10, MarketSeries.OpenTime[index]);
            var index10 = GetIndexByTime(seriesTF2, MarketSeries.OpenTime[index]);
            if (index10 != -1)
                MATF2[index] = maTF2.Result[index10];
        }


        private int GetIndexByDate(MarketSeries series, DateTime time)
        {
            for (int i = series.Close.Count - 1; i > 0; i--)
            {
                if (time == series.OpenTime[i])
                    return i;
            }
            return -1;
        }

        private int GetIndexByTime(MarketSeries searchSeries, DateTime desiredTime)
        {

            //loop over time series backwards till closest match found
            for (int i = searchSeries.Close.Count - 1; i > 0; i--)
            {
                if (desiredTime == searchSeries.OpenTime[i])
                {
                    return i;
                }
                else if (searchSeries.OpenTime[i] < desiredTime)
                    return i;
                //return last value prev. to desired
            }
            return -1;
        }
    }
}
