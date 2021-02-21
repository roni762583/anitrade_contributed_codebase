using System;
using System.Linq;
using cAlgo.API;
using cAlgo.API.Indicators;
using cAlgo.API.Internals;
using cAlgo.Indicators;
using System.Collections.Generic;

namespace cAlgo
{
    [Robot(TimeZone = TimeZones.UTC, AccessRights = AccessRights.None)]
    public class NewScalper2 : Robot
    {
        [Parameter(DefaultValue = 30)]
        public double TpTicks { get; set; }

        [Parameter(DefaultValue = 300)]
        public double HdgTicks { get; set; }


        [Parameter(DefaultValue = 24)]
        public int StaleHrs { get; set; }

        string label = "NewScalper2";

        //factor to convert pips to ticks
        double f;
        //direction of last hedge
        TradeType dir;
        //my open position
        Position myPos;
        //allow trade flag as safety to prevent rapid fire orders
        bool tradeOn = true;
        
        protected override void OnStart()
        {
            // factor for converting pips to ticks
            f = (Symbol.PipSize / Symbol.TickSize);
            //arbitrary direction to start scalping in 
            dir = TradeType.Buy;
            //timer for stale
            Timer.Start(StaleHrs*3600);//start timer with 1 second interval
        }

        protected override void OnTimer()
        {
            foreach (var pos in Positions)
            {
                if (pos.EntryTime.AddHours(StaleHrs) < Time)
                {
                    ClosePositionAsync(pos, OnCloseAsync);
                }
            }
        }

        protected override void OnTick()
        {
            //if open position reached T/P
            if (myPos!=null && myPos.Pips * f >= TpTicks)
            {
                ClosePositionAsync(myPos, OnCloseAsync);
            }

            //if open position reached hedge (hedge or close it - experimental)
            if (myPos!=null && myPos.Pips * f <= -HdgTicks && tradeOn)
            {//get hdg direction
                dir = myPos.TradeType == TradeType.Buy ? TradeType.Sell : TradeType.Buy;
                //hdg
                tradeOn = false;
                ExecuteMarketOrderAsync(dir, Symbol, myPos.Volume, label, 0.0, 0.0, null, "hdg", OnExecuted);
            }

            //if no open position, open in direction of last hedge
            if (myPos == null && tradeOn)
            {
                tradeOn = false;
                ExecuteMarketOrderAsync(dir, Symbol, GetVolume(), label, 0.0, 0.0, null, "1st", OnExecuted);
            }
        }

        private void OnCloseAsync(TradeResult tr)
        {
            if (tr != null && tr.IsSuccessful) myPos = null;
        }

        private long GetVolume() {return 1000L;}

        private void OnExecuted(TradeResult result)
        {
            if (result.IsSuccessful)
            {
                if (result.Position.Comment == "hdg")
                {
                    myPos = null;
                    tradeOn = true;
                    PrintHdgNet();
                }
                else
                {
                    myPos = result.Position;
                    tradeOn = true;
                }
            }
        }

        private void PrintHdgNet()
        {
            double net = 0.0;
            foreach (var pos in Positions)
            {
                if (pos.Comment == "hdg") net += pos.NetProfit;
            }
            Print("Net Hdg {0}", net);
        }

        protected override void OnStop() {}
     //class   
    }
    //namespace
}
