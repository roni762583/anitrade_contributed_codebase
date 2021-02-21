//super simple scalper

using System;
using System.Linq;
using cAlgo.API;
using cAlgo.API.Indicators;
using cAlgo.API.Internals;
using cAlgo.Indicators;

using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;

namespace cAlgo
{
    [Robot(TimeZone = TimeZones.UTC, AccessRights = AccessRights.None)]
    public class SSS : Robot
    {
        [Parameter(DefaultValue = 0.25)]
        public double netTarget { get; set; }

        [Parameter(DefaultValue = -2.25)]
        public double drawD2Hedge { get; set; }

        [Parameter(DefaultValue = 0.1)]
        public double volumeAmplificationPercent { get; set; }

        [Parameter(DefaultValue = 1000)]
        public double initialVolume { get; set; }

        [Parameter(DefaultValue = false)]
        public bool useMoneyManagement { get; set; }

        [Parameter("Money Mgmt. Risk Estimate (decimal)", DefaultValue = 0.25)]
        public double mmRisk { get; set; }

        string label = "SSS";
        List<TradeOperation> executingTradeOperationsList = new List<TradeOperation>();

        protected override void OnStart()
        {
            // Put your initialization logic here
            //events registration
            Positions.Closed += PositionsOnClosed;
            Positions.Opened += PositionsOnOpened;
            //add code to build lists of pending orders, open orders
        }

        private void PositionsOnOpened(PositionOpenedEventArgs obj)
        {
            //throw new NotImplementedException();
        }

        private void PositionsOnClosed(PositionClosedEventArgs obj)
        {
            //throw new NotImplementedException();
        }

        protected override void OnTick()
        {

            if (OpenPositions())
                CheckForExit();
            else
                CheckForEntry();

        }

        private void CheckForExit()
        {
            double tnpl = TotalNetPL();
            //net P/L of all positions this cBot and Symbol
            //if initial t/p reached, exit all positions
            if (tnpl >= netTarget)
            {
                CloseAllPositionsThisBotSymbol();
                return;
            }

            //update positions array
            var p = Positions.FindAll(label, Symbol);

            if (p != null)
            {

                //calc vol for possible rebalance (may need to optimize this calc.)
                //long vol = (long)(p.Length + 1) * 1000;

                //if only one position open, and max DD reached, open hedge trade
                if (p.Length == 1 && tnpl <= drawD2Hedge)
                {
                    //open hedge position in direction opposite to initial trade
                    OpenHedge(p[0].TradeType == TradeType.Buy ? TradeType.Sell : TradeType.Buy, GetHedgeVolume());
                    //go opposit initial trade
                    return;
                }

                //if more than one position open,...
                if (p.Length > 1)
                {
                    //Assuming that .FindAll() returns array ordered as expected - this code should be improved

                    //rebalance volume 
                    //vol = (long)(p.Length + 1) * 1000; //may need to be better optimized later
                    //vol = GetVolumeToBrkEvn(GetPLatTarget(s_LowerTarget, s_PosArr), s_TargetBelowZone);
                    double e0 = p[0].EntryPrice;
                    double e1 = p[1].EntryPrice;
                    double upperThreshold, lowerThreshold;
                    if (e0 > e1)
                    {
                        upperThreshold = e0;
                        lowerThreshold = e1;
                    }
                    else
                    {
                        upperThreshold = e1;
                        lowerThreshold = e0;
                    }

                    //if price reached above upperThreshold ....
                    if (Symbol.Ask >= upperThreshold)
                    {
                        OpenHedge(TradeType.Buy, GetHedgeVolume());
                    }
                    if (Symbol.Bid < lowerThreshold)
                    {
                        OpenHedge(TradeType.Sell, GetHedgeVolume());
                    }
                }
                // if (p.Length > 1) 
            }
            //if(p!=null)
        }
        //method
        private long GetHedgeVolume()
        {
            /*
            var s = Positions.FindAll(label, Symbol, TradeType.Sell); //short positions
            var b = Positions.FindAll(label, Symbol, TradeType.Buy);  //long positions
            if(s!=null&&b!=null)
            {
                double totalShortVol = 0.0, totalLongVol = 0.0;
                foreach (var pos in s)
                {
                    totalShortVol += pos.Volume;
                }
                foreach (var pos in b)
                {
                    totalLongVol += pos.Volume;
                }
            }
            return totalLongVol> totalShortVol ? volumeAmplificationPercent
            */
            return (long)(2 * initialVolume);
        }

        private void OpenHedge(TradeType tt, long vol)
        {
            ExecuteMarketOrder(tt, Symbol, vol, label, null, null, null, "hdg");
        }

        private double TotalNetPL()
        {
            double pltot = 0.0;
            foreach (var pos in Positions.FindAll(label, Symbol))
            {
                pltot += pos.NetProfit;
            }
            return pltot;
        }

        //not used due to problems
        private void FlattenPositions(Position[] psns)
        {

            //List<TradeOperation> executingTradeOperationsList = new List<TradeOperation>();
            if (psns != null)
                Print("hi from FlattenPositions()");
            foreach (var pos in psns)
            {
                TradeResult tr = ClosePosition(pos);
                if (tr.IsSuccessful)
                    Print("tr {0}", tr.IsSuccessful);
                else
                    Print("tr not successful, error {0}", tr.Error);
            }
        }
        /*
            TradeOperation t = ClosePositionAsync(pos, OnExecuted);
            if (t.IsExecuting)
                executingTradeOperationsList.Add(t);
            */


        private void CloseAllPositionsThisBotSymbol()
        {
            foreach (var pos in (Positions.FindAll(label, Symbol)))
            {
                ClosePosition(pos);
            }

        }


        // to check is all asynch trade operations have executed
        private bool AllTradeOperationsExecuted(List<TradeOperation> tol)
        {
            foreach (var to in tol)
            {
                if (to.IsExecuting)
                    return false;
            }
            return true;
        }


        private void OnExecuted(TradeResult result)
        {
            if (result.IsSuccessful)
            {
                Print("OnExecuted(): {0}, {1}", result.ToString(), result.Position.ToString());
            }
            else
            {
                Print("Failed to execute:{0}, with error: {1}", result.ToString(), result.Error);
            }
        }


        private double GetTotalPL(Position[] psns)
        {
            double plTotal = 0.0;
            foreach (var pos in psns)
            {
                plTotal += pos.NetProfit;
                Print("Pos {0} net: {1}, accumulative: {2}", pos.Id, pos.NetProfit, plTotal);
            }
            return plTotal;
        }


        private void CheckForEntry()
        {
            if (!TradingAllowed() || !AllTradeOperationsExecuted(executingTradeOperationsList))
                return;

            int d = DirectionSignal();
            // get expert recommendtion for direction of trade
            if (d > 0)
            {
                EnterLong();
            }
            else if (d < 0)
            {
                EnterShort();
            }
            else
                return;
            // if direction = 0, don't trade
        }


        private long GetMMvol()
        {
            double m = Account.FreeMargin * mmRisk;
            double h = GetH();
            //typically the bid
            double s = (double)Symbol.LotSize;
            // 100000 ?
            long lots = (long)(h * s / m);
            return Symbol.NormalizeVolume(lots, RoundingMode.Down);
        }

        private double GetH()
        {
            string home_currency = Account.Currency;
            string symbol = Symbol.Code;
            string base_currency = symbol.Substring(0, 3);
            string quote_currency = symbol.Substring(3, 3);
            double home_rate;
            //int margin_ratio;
            //double units;
            //double margin_required;

            if (home_currency == base_currency || home_currency == quote_currency)
            {
                home_rate = MarketData.GetSymbol(symbol).Bid;
            }
            else
            {
                home_rate = GetHomeRate(home_currency, base_currency);
            }

            //margin_ratio = Account.Leverage;
            //units = (double)Symbol.LotSize * lots;
            //margin_required = RoundUp(((home_rate) * units) / margin_ratio, 2);

            return home_rate;
        }

        private double GetHomeRate(string fromCurrency, string toCurrency)
        {
            Symbol symbol = TryGetSymbol(fromCurrency + toCurrency);

            if (symbol != null)
            {
                return symbol.Bid;
            }

            symbol = TryGetSymbol(toCurrency + fromCurrency);
            return symbol.Bid;
        }


        private Symbol TryGetSymbol(string symbolCode)
        {
            try
            {
                Symbol symbol = MarketData.GetSymbol(symbolCode);
                if (symbol.Bid == 0.0)
                    return null;
                return symbol;
            } catch
            {
                return null;
            }
        }


        public static double RoundUp(double input, int places)
        {
            double multiplier = Math.Pow(10, Convert.ToDouble(places));
            return Math.Ceiling(input * multiplier) / multiplier;
        }


        private void EnterLong()
        {
            long vol = GetVolume();
            ExecuteMarketOrder(TradeType.Buy, Symbol, vol, label, null, null, null, "sync");
            //just for testing

        }
        /*
            TradeOperation operation = 
            ExecuteMarketOrderAsync(TradeType.Buy, Symbol, vol, PositionOpened);
            if (operation.IsExecuting) Print("Executing Buy {0} {1}", vol, Symbol);
            */


        private void EnterShort()
        {
            long vol = GetVolume();
            ExecuteMarketOrder(TradeType.Sell, Symbol, vol, label, null, null, null, "sync");
            //just for testing

        }
        /*
            TradeOperation operation =
            ExecuteMarketOrderAsync(TradeType.Sell, Symbol, vol, PositionOpened);
            if (operation.IsExecuting) Print("Executing Sell {0} {1}", vol, Symbol);
            */


        private long GetVolume()
        {
            return useMoneyManagement ? GetMMvol() : (long)initialVolume;
        }

        private void PositionOpened(TradeResult obj)
        {
            //throw new NotImplementedException();
        }

        private int DirectionSignal()
        {
            return 1;
            // (+)long, (-)short, 0-none
        }

        private bool TradingAllowed()
        {
            //criteria to allow trading such as minimum ATR, momentum, slope, acceleration, etc.
            return true;
        }

        private bool OpenPositions()
        {
            return Positions.Count > 0 ? true : false;
        }

        protected override void OnStop()
        {
            // Put your deinitialization logic here
        }




    }
    //class
}
//namespace
//if (Positions.FindAll(label, Symbol)!=null && Positions.FindAll(label, Symbol).Length==0)
//{//if no open positions, enter
//    ExecuteMarketOrder(TradeType.Buy, Symbol, 1000, label, null, null, null, "1");
//}

//if(Positions.FindAll(label, Symbol) != null)
//{
//    double pl = 0.0;
//    //calc total net p/l
//    foreach (var pos in Positions.FindAll(label, Symbol) )
//    {
//        pl += pos.NetProfit;
//    }
//    if (pl >= netTarget)//if total net reached target, flatten all positions
//    {
//        foreach (var pos in Positions.FindAll(label, Symbol))
//        {
//            ClosePosition(pos);
//        }
//    }

/*
This calculation uses the following formula:

({BASE} / {Home Currency}) * units) / (margin ratio)

For example, suppose:

Home Currency = USD
Currency Pair = GBP / CHF
Base = GBP; Quote = CHF
Base / Home Currency = GBP / USD = 1.5819
Units = 1000
Margin Ratio = 20:1

Then, margin used:
= (1.5819 * 1000) / 20
= 79.095 USD

Read more: http://forums.babypips.com/forextown/75285-margin-required-indicator.html#ixzz3kaEh1PY4    
*/
