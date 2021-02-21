using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using cAlgo;
using cAlgo.API;
using cAlgo.API.Indicators;
using cAlgo.API.Internals;
using cAlgo.Indicators;


namespace cAlgo
{
    internal abstract class Strategy
    {

        //props
        internal MultiStage3 cBot { get; private set; }
        //rules
        //resources subscribed to
        public string Name { get; protected set; }
        public string Code { get; set; }
        public Object[] Parameters { get; set; }

        //c'tor - gets ref to initiating cBot
        public Strategy(Object[] parameters, MultiStage3 value)
        {
            this.cBot = value;
            //this.Name = this.GetType().Name;
            this.Parameters = parameters;
            this.Code = this.Name + string.Concat(parameters);
        }
        //methods
        abstract public int Check(); //method checks conditions for action s.a. entry, exit as applicable
    }

    internal class PsarStrategy : Strategy
    {
        //[Parameter("minAF", DefaultValue = 0.002)]
        public double minAF { get; set; }
        //[Parameter("maxAF", DefaultValue = 0.02)]
        public double maxAF { get; set; }

        ParabolicSAR psar;

        //c'tor
        public PsarStrategy(MultiStage3 value) : base(value)
        {//can add another c'tor to take params minAF, etc.
            this.minAF = 0.002;
            this.maxAF = 0.02;
        }
        public override int Check()
        {
            cBot.Print("hi from psar");
            return 0;
        }
    }



    internal class PingPongStrategy : Strategy
    {
        public int ticksBeyondVWAEforRebalance { get; set; }//level to rebalance at
        //public int sRcushionTicks { get; set; }//# of ticks b4 s/r as cushion for target

        //c'tor
        public PingPongStrategy(Object[] parameters, MultiStage3 cBot) : base(parameters, cBot)
        {//can add another c'tor to take params minAF, etc.
            this.ticksBeyondVWAEforRebalance = 100;
            //this.sRcushionTicks = 50;
            this.Name = "pingpong";
        }
        public override int Check()
        {
            cBot.Print("hi from pingpong");

            //Since more than one position can be assigned to the exit strategy after entry 
            //from other (entry)strategies. Instead of the initial position entry price providing 
            //an anchor for calculating hedge zone, and targets as in the current scalper which 
            //works one position at a time, this new version will:

            //-get list of positions assigned to ping pong exit strategy from Positions Table
            var pdto = base.cBot.dataOps.pdto;
            //var psns = pdto.GetPosIDsFromTable(this.Name); //psns IDs for this exit
            var psns = pdto.GetPosRefListFromPosTableByAssignedExit(this.Name);

            //a Dictionary of SortedPositions obj for each symbol in table
            //S.P. obj has: volume weighed average entry price for long and short psns
            var myBigDic = GetSortedPositionsDictionary(psns, cBot);

            //check if price is ticksBeyondVWAEforRebalance number of ticks beyond
            //the VWAE, and re - balance positions to hedge in direction
            foreach (var symKey in myBigDic.Keys)//loop over SP's by symbol
            {
                var sp = myBigDic[symKey];
                Symbol sym = cBot.MarketData.GetSymbol(sp.Symbol);
                var bid = sym.Bid;
                var ask = sym.Ask;
                bool atLongThld = ask >= sp.VolWdEntryPrcLong + ticksBeyondVWAEforRebalance * cBot.Symbol.TickSize;
                bool atShortThld = bid <= sp.VolWdEntryPrcShort - ticksBeyondVWAEforRebalance * cBot.Symbol.TickSize;
                //the above should be based on minimum separation between entry avgs set as parameter, 
                //and considering S/R levels, to set hedge levels
                //for now, forgo S/R, and implement this like so
                if (atLongThld) 
                {//hedge long
                    var hedgeDir = TradeType.Buy;
                    double Target = GetTarget(sp);
                }
                if (atShortThld)
                {
                }
            }
            //short with volume to break even at a price level that is above the nearest support 
            //level that does not dictate a hedge position too large(as a set % of acct equity), 
            //otherwise, take the next lower price target (that which is above the next lower support 
            //level.i.e.further away from vweps)

            //-vise versa for long side hedge on price a set dist.above vwepl to re - balance to break 
            //even or better at target just below next resistance level (unless this dictates too large 
            //a hedge position(as % of equity)), in which case use a target price level that is just 
            //below the next higher support level (i.e.further away from vwepl)

            //+In all cases, have net P/ L confirm calculations on exit 
            //                (verify net profit > 0, don't just exit by calculate target price)

            
            long rebHedgeVol = GetHedgeVol(hedgeDir);////place holder, to be populated with hedge direction
            var symbol = cBot.Symbol;
            GetNetPL(symbol);
            GetSRGrid(); //calculates a grid of S/R values
            double tooTightSR = 1.2000;//place holder, to be populated with prev. S/R that produced too big hedge volume
            GetNextSRLevel(hedgeDir, tooTightSR);
            
            return 0;
            //Check()
        }

        internal Dictionary<string, SortedPositions> GetSortedPositionsDictionary(List<Position> psns, MultiStage3 cBot)
        {//from pos. ref. list, returns dictionary of sorted psns by symbol as key
            var dic = new Dictionary<string, SortedPositions>();
            foreach (var pos in psns)
            {
                if (!dic.ContainsKey(pos.SymbolCode))
                {//if this symbol does not exist in dictionary, create a SortedPositions obj for it
                    dic.Add(pos.SymbolCode, new SortedPositions(pos.SymbolCode, cBot));
                }
                else
                {//if this symbol key exists in dictionary, add this position to the SortedPosition obj
                    SortedPositions sp;
                    var result = dic.TryGetValue(pos.SymbolCode, out sp);
                    if (result) sp.AddPosition(pos);
                    dic[pos.SymbolCode] = sp;
                }
            }
            foreach (SortedPositions sp in dic.Values)
            {//now that all S.P. obj are populated, call UpdateAll() on each to calc. stats.
                sp.UpdateAll();
            }
            return dic;
            //GetSortedPositionsDictionary
        }

        private List<Position> BuildPosRefListFromPosIDs(List<string> posIDs)
        {//this function returns a list of references to position objects based onpos ID list
            List<Position> psLst = new List<Position>();
            foreach (var posID in posIDs)
            {
                var rslt = cBot.Positions.Where(p => p.Id.ToString() == posID).FirstOrDefault();
                if (rslt != null) psLst.Add(rslt);
                else
                {
                    string msg = "BuildPosRefListFromPosIDs() could not locate posID " + posID + "in live positions";
                    cBot.SendAlert(msg);
                }
            }
            return psLst;
        }

        private List<string> GetShortPsns(List<string> bigIdList)
        {
            //returns a list of Short position IDs in the bigIdList
            var shrt = new List<string>();
            foreach (var posId in bigIdList)
            {
                Position psn = cBot.Positions.Where(p => p.Id.ToString() == posId).First();//.Where(q=>q.TradeType==TradeType.Buy);
                if (psn.TradeType == TradeType.Sell) shrt.Add(psn.Id.ToString());
            }
            return shrt;
        }

        private List<string> GetLongPsns(List<string> bigIdList)
        {
            //returns a list of Long position IDs in the bigIdList
            var lng = new List<string>();
            foreach (var posId in bigIdList)
            {
                Position psn = cBot.Positions.Where(p => p.Id.ToString() == posId).First();//.Where(q=>q.TradeType==TradeType.Buy);
                if (psn.TradeType == TradeType.Buy) lng.Add(psn.Id.ToString());
            }
            return lng;
        }

        private double GetVWEP(List<string> longPsnIDs)
        {
            //returns the volume weighed averace entry price for a list of positions
            double sumProducts = 0.0;
            double sumVol = 0.0;
            foreach (var posId in longPsnIDs)
            {
                Position p = cBot.Positions.Where(ps => ps.Id.ToString() == posId).First();
                sumProducts += p.EntryPrice * p.Volume;
                sumVol += p.Volume;
            }
            return sumProducts / sumVol;
        }

        private long GetHedgeVol(TradeType hedgeDir)
        {
            long breakEvenVol = 100000000000L;//to be replaced with algo calculating this
            return breakEvenVol;
        }

        private void GetNextSRLevel(TradeType hedgeDir, double beyondPrice)
        {//
            //returns the next S/R level in grid in direction beyond price
        }

        private void GetNetPL(Symbol symbol)
        {
            //return actual current net P/L sum of all positions this symbol and assigned exit
        }

        private void GetSRGrid()
        {
            //- I have a S / R algo that I developed in earlier years, or can use the simpler pivot points as published
            //Pivot Point = (High + Low + Close) /3
            //#1 high pivot = Pivot Point + (Pivot Point - Low)
            //#1 low pivot = Pivot Point - (High - Pivot Point)
            //#2 high pivot = Pivot Point + 2 (Pivot Point - Low)
            //#2 low pivot = Pivot Point - 2 (High - Pivot Point)
            //#3 high pivot = High + 2 (Pivot Point - Low)
            //#3 low pivot = Low - 2 (High - Pivot Point)
            //
            //Alt. calc.
            //            Formula Used:
            //Pivot Point = (H + C + L) / 3
            //R3 = H + 2 × (Pivot − L ) 
            //R2 = Pivot + (R1 − S1 ) 
            //R1 = 2 × Pivot − L
            //S1 = 2 × Pivot − H
            //S2 = Pivot − (R1 − S1 ) 
            //S3 = L − 2 × (H − Pivot )

            //Where, 
            //H - Previous Days High
            //L - Previous Days Low
            //C - Previous Days Close
            //R - Resistances Levels
            //S - Supports Levels
            //
            //Alt. & in combination:
            //round to 2 zeros at end of price not including ticks. 
            //ex. 1.34567 -> 1.34000, 1.34500, nearest 50 is good i guess
            //
            //alt. swing Highs & Lows
            //where price had a difficult time breaking through. As price 
            //moves up and down, each level that price has bounced off of 
            //could be a level in the future that price bounces off of again.

            //a combination of all the above

        }

        internal void PingPongExit()
        {
            //this.cBot.UpdatePositionsArray();

            //int numberOfPositions = this.cBot.allPositions.Length;

            ////if only 1 position exists...
            //if (numberOfPositions == 1 && this.cBot.allPositions[0].Comment == "1st")
            //{
            //    //zone not set...set it
            //    if (this.cBot.lowerZoneBoundry == 0.0)
            //    {
            //        //calculate zone and targets based on initial entry
            //        lowerZoneBoundry = allPositions[0].EntryPrice - halfZoneTicks * Symbol.TickSize;
            //        upperZoneBoundry = allPositions[0].EntryPrice + halfZoneTicks * Symbol.TickSize;
            //        upperTarget = upperZoneBoundry + targetBeyondZoneTicks * Symbol.TickSize;
            //        lowerTarget = lowerZoneBoundry - targetBeyondZoneTicks * Symbol.TickSize;
            //    }

            //    double tradeDir = allPositions[0].TradeType == TradeType.Buy ? 1.0 : -1.0;
            //    double sig = 0.0;
            //    // lrfpsar.Signal.LastValue;
            //    //if indicator in direction of trade, return
            //    if ((tradeDir > 0 && sig > 0) || (tradeDir < 0 && sig < 0))
            //    {

            //        return;
            //        //if opposing, it will check t/p below
            //    }
            //    //if 1st leg reached initial target, close it
            //    if (allPositions[0].Pips * factor >= initTargetTicks)
            //    {

            //        CloseAllPositionsThisBotAndSymbol();
            //    }
            //}

            ////if price moves beyond upper zone boundry - rebalance for b/e (or better by profit factor parameter) on the upper target (ask price)
            ////else if price moves beyond lower zone boundry - rebalance for b/e or better on the lower target (bid)
            //if (Symbol.Ask >= upperZoneBoundry)
            //{
            //    long vol = GetVolumeToBrkEvn(GetPLatTarget(upperTarget), targetBeyondZoneTicks);

            //    if (vol > 0)
            //    {
            //        var tr = ExecuteMarketOrder(TradeType.Buy, Symbol, vol, label, null, null, null, "not 1st");
            //    }
            //}

            //if (Symbol.Bid <= lowerZoneBoundry)
            //{
            //    long vol = GetVolumeToBrkEvn(GetPLatTarget(lowerTarget), targetBeyondZoneTicks);
            //    if (vol > 0)
            //    {
            //        var tr = ExecuteMarketOrder(TradeType.Sell, Symbol, vol, label, null, null, null, "not 1st");
            //    }
            //}

            //UpdatePositionsArray();

            //// if price at either upper, or lower targets; close all legs
            //if (Symbol.Bid >= upperTarget || Symbol.Ask <= lowerTarget)
            //{
            //    CloseAllPositionsThisBotAndSymbol();
            //}
            //return;
            //// PingPongExit()
        }
        //class PingPongStrategy
    }



}
