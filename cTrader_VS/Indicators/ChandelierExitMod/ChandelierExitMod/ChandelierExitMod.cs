using System;
using cAlgo.API;
using cAlgo.API.Internals;
using cAlgo.API.Indicators;

namespace cAlgo
{
    [Indicator(IsOverlay = true, TimeZone = TimeZones.UTC, AccessRights = AccessRights.None)]
    public class ChandelierExitMod : Indicator
    {
        [Parameter(DefaultValue = 14)]
        public int Period { get; set; }

        [Parameter(DefaultValue = 3)]
        public double AtrMultiplier { get; set; }

        /*, Thickness = 1*/        [Output("LongExit", PlotType = PlotType.Line, Color = Colors.Blue)]
        public IndicatorDataSeries LongExit { get; set; }

        /* , Thickness = 1*/        [Output("ShortExit", PlotType = PlotType.Line, Color = Colors.Red)]
        public IndicatorDataSeries ShortExit { get; set; }


        private AverageTrueRange _atr;

        protected override void Initialize()
        {
            _atr = Indicators.AverageTrueRange(Period, MovingAverageType.Exponential);
        }

        public override void Calculate(int index)
        {
            var highestHigh = MarketSeries.High.Maximum(Period);
            var lowestLow = MarketSeries.Low.Minimum(Period);
            var adjustedAtr = _atr.Result[index] * AtrMultiplier;

            var longExit = highestHigh - adjustedAtr;
            var shortExit = lowestLow + adjustedAtr;

            // if (!double.IsNaN(LongExit[index - 1]))
            // {
                        /*
                if (MarketSeries.Close[index - 1] < LongExit[index - 1])
                    ShortExit[index] = shortExit;
                else
                    LongExit[index] = longExit;
            }
            else
            {
                if (MarketSeries.Close[index - 1] > ShortExit[index - 1])
                    LongExit[index] = longExit;
                else
                    ShortExit[index] = shortExit;
            
                */
LongExit[index] = longExit;
            ShortExit[index] = shortExit;
            // }
        }
    }
}
