using System;
using System.Linq;
using cAlgo.API;
using cAlgo.API.Indicators;
using cAlgo.API.Internals;
using cAlgo.Indicators;

namespace cAlgo
{
    [Robot(TimeZone = TimeZones.UTC, AccessRights = AccessRights.None)]
    public class Justin_cBot_2_mod : Robot
    {
        [Parameter("Max trades per sequence", DefaultValue = 100)]
        public static int maxTradesPerSequence { get; set; }

        private const string label = "Justin_cBot_2_mod";

        private class JTrade
        {
            public TradeResult tradeResult = null;

            public int profitPips = 0;
            public int hedgePips = 0;
        }

        private JTrade[] jTrades = null;

        private int jTradesIndex = -1;

        protected override void OnStart()
        {
            // Put your initialization logic here 
        }

        protected override void OnTick()
        {
            // Put your core logic here

            if (jTrades == null)
            {
                var vol = 1000;

                TradeResult result = ExecuteMarketOrder(TradeType.Sell, Symbol, vol, label + " : " + "Initial", null, null, null, "Initial");

                if (result.IsSuccessful)
                {
                    // Print("Sell at {0}", result.Position.EntryPrice);

                    jTrades = new JTrade[maxTradesPerSequence];

                    jTrades[0] = new JTrade();

                    jTrades[0].profitPips = 30;
                    jTrades[0].hedgePips = -400;

                    jTrades[0].tradeResult = result;

                    jTradesIndex = 0;
                }
            }
            else
            {
                //Print("jTrades[" + jTradesIndex + "].tradeResult.Position.Pips = ", jTrades[jTradesIndex].tradeResult.Position.Pips);

                if (jTrades[jTradesIndex].tradeResult.Position.Pips >= jTrades[jTradesIndex].profitPips)
                {
                    // Sequence ends profitably: take profits and continue trading
                    //
                    closeSequence();
                }
                else if (jTrades[jTradesIndex].tradeResult.Position.Pips <= jTrades[jTradesIndex].hedgePips)
                {
                    // Hedging level is reached for the current trade in the sequence: open
                    // a hedging position or close the seqeunce
                    //
                    if (jTradesIndex < maxTradesPerSequence - 1)
                    {
                        // A hedging trade can be opened
                        //
                        jTradesIndex++;

                        var vol = 3000;

                        if (jTradesIndex > 1)
                        {
                            vol = 5000 * (int)Math.Pow(2, jTradesIndex - 2);
                        }
                        /*
                        TradeType tradeType = TradeType.Buy;

                        if (jTradesIndex % 2 == 0)
                        {
                            tradeType = TradeType.Sell;
                        }*/
                        TradeType tradeType = jTradesIndex % 2 == 0 ? tradeType = TradeType.Sell : TradeType.Buy;

                        TradeResult result = ExecuteMarketOrder(tradeType, Symbol, vol, label + " : " + jTradesIndex, null, null, null, "Trade " + jTradesIndex);

                        if (result.IsSuccessful)
                        {
                            // if (tradeType == TradeType.Buy)
                            // {
                            //    Print("Buy at {0}", result.Position.EntryPrice);
                            // }
                            // else
                            // {
                            //      Print("Sell at {0}", result.Position.EntryPrice);
                            // }

                            jTrades[jTradesIndex] = new JTrade();

                            jTrades[jTradesIndex].profitPips = 400;
                            jTrades[jTradesIndex].hedgePips = -400;

                            jTrades[jTradesIndex].tradeResult = result;
                        }
                    }
                    else
                    {
                        // Sequence ends unprofitably: take losses and continue trading
                        //
                        closeSequence();
                    }

                }
            }
        }

        protected override void OnStop()
        {
            // Put your deinitialization logic here
        }

        private void closeSequence()
        {

            TradeResult result = null;
            /*
            for (int i = 0; i <= jTradesIndex; i++)
            {
                result = ClosePosition(jTrades[i].tradeResult.Position);
            }*/
            foreach (var trd in jTrades)
            {
                result = ClosePosition(trd.tradeResult.Position);
            }
            jTrades = null;
            jTradesIndex = -1;
        }
    }
}

