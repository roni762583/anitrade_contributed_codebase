using System;
using System.Linq;
using cAlgo.API;
using cAlgo.API.Indicators;
using cAlgo.API.Internals;
using cAlgo.Indicators;

namespace cAlgo
{
    [Robot(TimeZone = TimeZones.UTC, AccessRights = AccessRights.None)]
    public class aroon : Robot
    {
        //[Parameter(DefaultValue = 2.0)]
        //public double minPips { get; set; }

        [Parameter(DefaultValue = 25)]
        public int period { get; set; }

        [Parameter(DefaultValue = 0.3)]
        public double maxSlip { get; set; }

        //[Parameter(DefaultValue = 50)]
        //public int maxPosintions { get; set; }

        //[Parameter(DefaultValue = 0.3)]
        //public double maxRatioDiff { get; set; }

        [Parameter(DefaultValue = 3000)]
        public double reorderDelayMsec { get; set; }

        //[Parameter(DefaultValue = 0.005)]
        //public double sumScalpPct { get; set; }

        //private ExponentialMovingAverage ema;
        private DateTime lastPositionOpenTime;
        //private double lastAcctFlatEquity;

        private Aroon ar;
        bool delaySatisfied;
        string label = "254";

        protected override void OnStart()
        {
            //ema = Indicators.ExponentialMovingAverage(MarketSeries.Close, period);
            ar = Indicators.Aroon(period);
            Positions.Opened += PositionsOnOpened;
            Positions.Closed += PositionsOnClosed;
        }

        private void PositionsOnOpened(PositionOpenedEventArgs args)
        {
            var pos = args.Position;
            lastPositionOpenTime = pos.EntryTime;
            //string txt = "OnOpened()";
            //SendNotificationEmail(pos, txt);
        }

        private void PositionsOnClosed(PositionClosedEventArgs args)
        {
            var pos = args.Position;
            //string txt = "OnClosed(), {0}, P/L" + pos.NetProfit.ToString();
            //SendNotificationEmail(pos, txt);
        }


        protected override void OnTick()
        {
            //if all positions on account result in increasing acct. equity by % from last
            //double acctPctChg = Account.Equity / Account.Balance - 1.0;
            //if (acctPctChg > sumScalpPct)
            //    CloseAllPositions();

            delaySatisfied = Time.Subtract(lastPositionOpenTime).TotalMilliseconds >= reorderDelayMsec;

            //if (delaySatisfied)
            //{
            //double emaLast = ema.Result.LastValue;
            //bool shrtSig = (emaLast < Symbol.Bid - minPips * Symbol.PipSize);
            //bool lngSig = (emaLast > Symbol.Ask + minPips * Symbol.PipSize);
            //int totCnt = 0;
            //// Positions.FindAll(label, Symbol).Length;
            //int shrtCnt = 0;
            //// Positions.FindAll(label, Symbol, TradeType.Sell);
            //int lngCnt = 0;
            //long lngVol = 0L, shrtVol = 0L;
            //foreach (var pos in Positions.FindAll(label, Symbol))
            //{
            //    totCnt += 1;
            //    if (pos.TradeType == TradeType.Sell)
            //    {
            //        shrtCnt += 1;
            //        shrtVol += pos.Volume;
            //    }
            //    else
            //    {
            //        lngCnt += 1;
            //        lngVol += pos.Volume;
            //    }
            //}
            //double den = (shrtVol + shrtVol);
            //double lngRatioPct = den == 0 ? 0 : lngVol / den;
            //double shrtRatioPct = den == 0 ? 0 : shrtVol / den;
        }
        protected override void OnBar()
        {
            if (delaySatisfied)
            {
                if (ar.Up.HasCrossedAbove(ar.Down, 0))
                {
                    CloseAllPositions();
                    ExecuteMarketOrder(TradeType.Buy, Symbol, 1000, label, null, null, maxSlip, "comment");
                }
                else if (ar.Up.HasCrossedBelow(ar.Down, 0))
                {
                    CloseAllPositions();
                    ExecuteMarketOrder(TradeType.Sell, Symbol, 1000, label, null, null, maxSlip, "comment");
                }
            }
        }

        private void CloseAllPositions()
        {
            foreach (var pos in Positions.FindAll(label, Symbol))
            {
                ClosePositionAsync(pos);
            }
        }

        protected override void OnStop()
        {
            // Put your deinitialization logic here
        }
    }
}
