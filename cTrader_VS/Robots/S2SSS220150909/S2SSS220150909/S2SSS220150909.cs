//super simple scalper 2 - use pips
//this version of the production long-only initiating, will short-only, then parallel both long and short, also need to fix money management and safety features such as 
//maximal losses switch, handling open positions after server restart, winding down open positions for shut down, etc.

using System;
using System.Linq;
using cAlgo.API;
using cAlgo.API.Indicators;
using cAlgo.API.Internals;
using cAlgo.Indicators;

//using System.Collections.Generic;
//using System.Text;
//using System.Threading.Tasks;

//using System.Windows.Forms;

namespace cAlgo
{
    [Robot(TimeZone = TimeZones.UTC, AccessRights = AccessRights.FullAccess)]
    public class S2SSS220150909 : Robot
    {
        //net money profit target
        [Parameter(DefaultValue = 0.1)]
        public double netProfitTarget { get; set; }

        //escalation factor for net money profit target during hedge
        [Parameter(DefaultValue = 1.28)]
        public double netProfitTargetEscalationFactor { get; set; }

        //adverse pips at which to hedge
        [Parameter(DefaultValue = 29)]
        public double pipDDhedge { get; set; }

        //factor to increase minimu hedge volume by
        [Parameter(DefaultValue = 1.7)]
        public double hedgeEscalationFactor { get; set; }

        //if set, use value, if set to zero, use money management rules
        [Parameter(DefaultValue = 0)]
        public double initialVolume { get; set; }

        //only used if initial volume set to zero
        [Parameter("Money Mgmt. Risk Estimate (decimal)", DefaultValue = 0.5)]
        public double mmRisk { get; set; }

        string label = "S2SSS220150909";

        protected override void OnStart()
        {

        }

        //protected void DisplayAlert(string text1, string text2, string text3, object o1, object o2)
        //{
        //    string text = string.Format("{0}, {1}, {2}\n{3}, {4}", text1, text2, text3, o1.ToString(), o2.ToString());
        //    string caption = "S2SSS220150909";

        //    DialogResult result = MessageBox.Show(text, caption, MessageBoxButtons.YesNoCancel, MessageBoxIcon.None, MessageBoxDefaultButton.Button1);

        //}

        protected override void OnTick()
        {
            if (Flat())
                CheckForEntry();
            else
                CheckForExit();
        }

        private bool Flat()
        {
            var posArr = Positions.FindAll(label, Symbol);
            if (posArr != null)
            {
                return posArr.Length == 0 ? true : false;
            }
            //in case null, don't enter new trades as consequence to using this method
            return false;
        }

        private void CheckForExit()
        {
            //get open positions
            var posArr = Positions.FindAll(label, Symbol);
            Position initPos = null;
            if (posArr != null && posArr.Length > 0)
            {
                initPos = posArr[0];
                if (initPos != null)
                {

                    //if netTargetPerInitVolume is reached, flatten all positions
                    long volDelta = posArr.Length > 1 ? Math.Abs(GetNthPositionVolume(0) - GetNthPositionVolume(1)) : 1000;
                    //get excess hedge volume, or 1000
                    //put Abs. in there due to situation of (-) volDelta causing loss (maybe due to partial fill of prev. leg???)
                    double factor = netProfitTargetEscalationFactor != 1 ? (netProfitTargetEscalationFactor * volDelta / 1000) : 1;

                    if (NetPL() >= netProfitTarget * factor)
                    {
                        FlattenAllPositionsThisBotSymbol();
                        return;
                    }

                    //if reached draw down setting, hedge
                    if (initPos.Pips < -Math.Abs(pipDDhedge))
                    {
                        var direction = initPos.TradeType == TradeType.Buy ? TradeType.Sell : TradeType.Buy;

                        if (NeedToRebalance(direction))
                            OpenHedge(direction, GetHedgeVolume());

                        return;
                    }

                    //if re-reached entry price, rebalance as necessary
                    //long case
                    if (initPos.TradeType == TradeType.Buy)
                    {
                        if (Symbol.Ask >= initPos.EntryPrice)
                        {
                            if (NeedToRebalance(TradeType.Buy))
                                OpenHedge(TradeType.Buy, GetHedgeVolume());
                            return;
                        }
                    }
                    //is a short
                    else
                    {
                        if (Symbol.Bid <= initPos.EntryPrice)
                        {
                            if (NeedToRebalance(TradeType.Sell))
                                OpenHedge(TradeType.Sell, GetHedgeVolume());
                            return;
                        }
                    }
                }
            }



        }

        private long GetNthPositionVolume(int i)
        {
            //gets volume of open position (this cBot and Symbol) at index i
            var p = Positions.FindAll(label, Symbol);
            if (p != null && p.Length > i)
            {
                return p[i].Volume;
            }
            else
                return 0L;
        }

        //CheckForExit()

        private bool NeedToRebalance(TradeType direction)
        {
            long longVol = 0L;
            long shrtVol = 0L;
            GetLongShortVolumes(ref longVol, ref shrtVol);
            if (direction == TradeType.Buy)
            {
                if (longVol > shrtVol)
                    return false;
                else
                    return true;
            }
            //short
            else
            {
                if (shrtVol > longVol)
                    return false;
                else
                    return true;
            }
        }

        private void GetLongShortVolumes(ref long longVol, ref long shrtVol)
        {
            longVol = 0;
            shrtVol = 0;
            foreach (var pos in Positions.FindAll(label, Symbol))
            {
                if (pos.TradeType == TradeType.Buy)
                    longVol += pos.Volume;
                else
                    shrtVol += pos.Volume;
            }
        }

        private double NetPL()
        {
            var posArr = Positions.FindAll(label, Symbol);
            if (posArr != null)
            {
                double totalNet = 0.0;
                foreach (var pos in posArr)
                {
                    totalNet += pos.NetProfit;
                }
                //Print("NetPL: {0}", totalNet);
                return totalNet;
            }
            Print("NetPL: {0}", "error");
            return -123456789.0;
            //error
        }

        private void CheckForEntry()
        {
            //DisplayAlert("CheckForEntry()", "", "", "", "");
            if (!TradingAllowed())
                return;

            // get expert recommendtion for direction of trade
            int d = DirectionSignal();

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
            // if direction == 0, don't trade
        }

        private void EnterLong()
        {
            long vol = GetVolume();
            var tr = ExecuteMarketOrder(TradeType.Buy, Symbol, vol, label, null, null, null, "1st");
            //DisplayAlert("EnterLong()", vol.ToString(),"", "", "");
        }

        private void EnterShort()
        {
            long vol = GetVolume();
            var tr = ExecuteMarketOrder(TradeType.Sell, Symbol, vol, label, null, null, null, "1st");
            //SetTradeVars(tr);
        }

        private void FlattenAllPositionsThisBotSymbol()
        {
            //Print("hi from closeAllPo..");
            foreach (var pos in (Positions.FindAll(label, Symbol)))
            {
                var pips = pos.Pips;
                TradeResult tr = ClosePosition(pos);
                //if (tr.IsSuccessful && pips < 0)
                //    Print("Pos ID {0} closed with {1} pips at {2} server time by FlattenAllPositionsThisBotSymbol()", pos.Id, pips, Time.ToShortTimeString());
            }
            //ZeroTradeVars();
        }

        private long GetHedgeVolume()
        {
            var v = GetLastPositionVolume();
            return (long)(Math.Ceiling(Math.Max(initialVolume + 1000, v) * hedgeEscalationFactor / 1000) * 1000);
        }

        private long GetLastPositionVolume()
        {
            var p = Positions.FindAll(label, Symbol);
            if (p != null && p.Length > 0)
            {
                return p[p.Length - 1].Volume;
            }
            else
                return 0L;
        }

        private void OpenHedge(TradeType tt, long vol)
        {
            long lng = 0, srt = 0;
            GetLongShortVolumes(ref lng, ref srt);
            //DisplayAlert("OpenHedge()", tt.ToString() ,vol.ToString(), lng, srt);
            ExecuteMarketOrder(tt, Symbol, vol, label, null, null, null, "hdg");
        }


        private int DirectionSignal()
        {
            return -1;
            // (+)long, (-)short, 0-none
        }

        private bool TradingAllowed()
        {
            //criteria to allow trading such as minimum ATR, momentum, slope, acceleration, etc.
            return true;
        }

        /// <summary> //these should be sectioned in class wrapper
        /// methods for getting trade volume for initial position
        /// GetMMvol() - returns trade volume based on risk setting and free margin, supports GetVolume()
        /// GetH() - supports above by getting 'home' rate
        /// GetHomeRate() - supports above
        /// TryGetSymbol() - supports above
        /// GetVolume() - end function that uses all above to get the trading volume
        /// </summary>
        /// <returns></returns>
        //used with GetVolume()
        private long GetMMvol()
        {

            double m = Account.FreeMargin * mmRisk;
            //mmRisk represents portion of free margin to be considered
            int f = Math.Max((int)(m / 1000.0), 1);
            //1000 will be min. volume
            long v = (long)f * 1000;
            //for every additional $1000 in portion of free margin, 1000 additional volume allocated
            return v;
            //double h = GetH();

            ////typically the bid
            //double s = (double)Symbol.LotSize;

            //double lots = (double)((h * s) / m);
            ////added multipli by -
            //Print("m={1}, h={0}, s={2}, lots={3}", h, m, s, lots);

            //return (long)Math.Ceiling(lots) * 1000;
            ////Symbol.NormalizeVolume(lots, RoundingMode.Down);

        }
        //used with GetMMvol()
        private double GetH()
        {
            string home_currency = Account.Currency;
            string symbol = Symbol.Code;
            string base_currency = symbol.Substring(0, 3);
            string quote_currency = symbol.Substring(3, 3);
            double home_rate;

            if (home_currency == base_currency || home_currency == quote_currency)
            {
                home_rate = MarketData.GetSymbol(symbol).Bid;
            }
            else
            {
                home_rate = GetHomeRate(home_currency, base_currency);
            }

            return home_rate;
        }
        //used with GetH()
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
        //used with GetHomeRate()
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
        private long GetVolume()
        {
            return initialVolume == 0 ? GetMMvol() : (long)initialVolume;
            //might ad code validating volume returned in increments of 1000 only
        }
        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    }
    //class
}
//namespace
