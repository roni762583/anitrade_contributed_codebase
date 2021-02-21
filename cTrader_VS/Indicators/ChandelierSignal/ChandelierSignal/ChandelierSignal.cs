using System;
using cAlgo.API;
using cAlgo.API.Internals;
using cAlgo.API.Indicators;

namespace cAlgo
{
    //to be used with EURUSD t10
    [Levels(0, 1, -1)]
    [Indicator(IsOverlay = false, TimeZone = TimeZones.UTC, AccessRights = AccessRights.None)]
    public class ChandelierSignal : Indicator
    {
        [Parameter(DefaultValue = 22)]
        public int Period { get; set; }

        [Parameter(DefaultValue = 3)]
        public double AtrMultiplier { get; set; }

        private IndicatorDataSeries _longLeaderDataSeries;

        private IndicatorDataSeries _shortLeaderDataSeries;

        [Output("EntrySignal", PlotType = PlotType.Line, Color = Colors.Red)]
        public IndicatorDataSeries EntrySignal { get; set; }

        [Output("ExitSignal", PlotType = PlotType.Line, Color = Colors.White)]
        public IndicatorDataSeries ExitSignal { get; set; }

        private AverageTrueRange _atr;

        protected override void Initialize()
        {
            _atr = Indicators.AverageTrueRange(Period, MovingAverageType.Exponential);
            _shortLeaderDataSeries = CreateDataSeries();
            _longLeaderDataSeries = CreateDataSeries();
        }

        public override void Calculate(int index)
        {
            var highestHigh = MarketSeries.High.Maximum(Period);
            var lowestLow = MarketSeries.Low.Minimum(Period);
            var adjustedAtr = _atr.Result[index] * AtrMultiplier;

            var longExit = highestHigh - adjustedAtr;
            var shortExit = lowestLow + adjustedAtr;

            //set lines values as data series
            _longLeaderDataSeries[index] = longExit;
            _shortLeaderDataSeries[index] = shortExit;

            //vars
            int s = 0;
            int e = 0;

            //condition to enter long
            if (MarketSeries.Close[index - 1] > _longLeaderDataSeries[index - 1] && MarketSeries.Close[index - 1] > _shortLeaderDataSeries[index - 1] && MarketSeries.Open[index] > _longLeaderDataSeries[index] && MarketSeries.Open[index] > _shortLeaderDataSeries[index])
                s = 1;

            //condition to enter short
            if (MarketSeries.Close[index - 1] < _longLeaderDataSeries[index - 1] && MarketSeries.Close[index - 1] < _shortLeaderDataSeries[index - 1] && MarketSeries.Open[index] < _longLeaderDataSeries[index] && MarketSeries.Open[index] < _shortLeaderDataSeries[index])
                s = -1;

            //set entry signal series
            EntrySignal[index] = s;


            //condition to flatten shorts
            if (MarketSeries.Close[index] > _longLeaderDataSeries[index] || MarketSeries.Close[index] > _shortLeaderDataSeries[index])
                e = 1;

            //condition to flatten longs
            if (MarketSeries.Close[index] < _longLeaderDataSeries[index] || MarketSeries.Close[index] < _shortLeaderDataSeries[index])
                e = -1;

            //set exit signal series
            ExitSignal[index] = e;
        }
    }
}
