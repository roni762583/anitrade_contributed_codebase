using System;
using cAlgo.API;
using cAlgo.API.Internals;
using cAlgo.API.Indicators;

namespace cAlgo
{
    //to be used with EURUSD t10
    [Levels(0, 1, -1)]
    [Indicator(IsOverlay = false, TimeZone = TimeZones.UTC, AccessRights = AccessRights.None)]
    public class AhilSignal : Indicator
    {
        [Parameter(DefaultValue = 200)]
        public int lookBack { get; set; }

        [Parameter(DefaultValue = 6)]
        public double AtrMultiplier { get; set; }

        //series for lines
        private IndicatorDataSeries _longExit;
        private IndicatorDataSeries _shortExit;
        
        [Output("ExitSignal", PlotType = PlotType.Line, Color = Colors.White)]
        public IndicatorDataSeries Signal { get; set; }

        private AverageTrueRange _atr;

        private bool isTick;
        private double prevAskMax, prevBidMax;
        
        CircularBuffer<double> _bids;
        CircularBuffer<double> _asks;

        protected override void Initialize()
        {
            _atr = Indicators.AverageTrueRange(lookBack, MovingAverageType.Exponential);
            _shortExit = CreateDataSeries();
            _longExit = CreateDataSeries();
            isTick = MarketSeries.TimeFrame.ToString() == "Tick" ? true : false;
            if(isTick)
            {
                //intantiate bid/ask buffers
                _bids = new CircularBuffer<double>(lookBack);
                _asks = new CircularBuffer<double>(lookBack);
            }

        }

        public override void Calculate(int index)
        {
            
            if (isTick)
            {
                //in case of using tick chart, price comparisons based on bid/ask price since in tick chart O=H=L=C=bid
                
                //add new ticks to buffers
                _bids.Add(Symbol.Bid);
                _asks.Add(Symbol.Ask);

                //calculate lines
                var highestHigh = _asks.GetMax();    //MarketSeries.High.Maximum(lookBack);
                var lowestLow = MarketSeries.Low.Minimum(lookBack);
                var adjustedAtr = _atr.Result[index] * AtrMultiplier;
                var longExit = highestHigh - adjustedAtr;
                var shortExit = lowestLow + adjustedAtr;
                

                //set lines values as data series
                _longExit[index] = longExit;
                _shortExit[index] = shortExit;

                
                if (_asks.IsPrimed && _bids.IsPrimed)
                {
                    if (_asks.GetPrevious() > _longExit[index - 1]) { }
                    prevAskMax=
                }


            }
            else
            {
/*
                //condition to enter long
                if (MarketSeries.Close[index - 1] > _longExit[index - 1] && MarketSeries.Close[index - 1] > _shortExit[index - 1] && MarketSeries.Open[index] > _longExit[index] && MarketSeries.Open[index] > _shortExit[index])
                    s = 1;

                //condition to enter short
                if (MarketSeries.Close[index - 1] < _longExit[index - 1] && MarketSeries.Close[index - 1] < _shortExit[index - 1] && MarketSeries.Open[index] < _longExit[index] && MarketSeries.Open[index] < _shortExit[index])
                    s = -1;

                //set entry signal series
                Signal[index] = s;


                //condition to flatten shorts
                if (MarketSeries.Close[index] > _longExit[index] || MarketSeries.Close[index] > _shortExit[index])
                    e = 1;

                //condition to flatten longs
                if (MarketSeries.Close[index] < _longExit[index] || MarketSeries.Close[index] < _shortExit[index])
                    e = -1;

                //set exit signal series
                Signal[index] = e;
*/
            }
        }
    }
}
