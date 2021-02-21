// -------------------------------------------------------------------------------------------------
//   Modified cBot Roni renamed to Roni_cBot
// plan of action: 1st build LRSBB_ind as basis for this cBot
// pingpong adverse exit
// --------------------------------------------------------------
// 13 July looks like close all doesn't work or never reaches, see log for print statements - problem that backtester didnt get result of ClosePositionAsynch
// 14 July : 02/06/2015 10:04:00.000 | Crashed in OnTick with IndexOutOfRangeException: Index was outside the bounds of the array.
// 15 July could not yet debug - sent request to ctdn forum
// 20 July changed if then statements and stopped getting exception - still dont know exact cause
// 22 July - used VS debugger by attaching to cAlgo process per:   http://help.spotware.com/calgo/visual-studio/debug-cbots
// checked for null reference - no exception, but not trading either!
// 03 Aug - wroteup and compiled formula for PingPong volume calc.:
// Much backtesting and optimizing pingpong exit shows that within limit, it can break even or better (GBPJPY, EURUSD) even when considering commissions
// 13 Aug - changed pips to ticks as parameter
// 16 Aug - find feasible parameters for scalping strategy to test on demo acct.
/*
 Formula for calculating Profit/Loss (P/L) for all legs of the PingPong exit strategy at any arbitrary price level. 
(This allows calculation of volume required in last leg for break even (B/E) on overall trade.)

P/L = Sum( p/l(i) ),
where p/l(i) is p/l of the ith leg of trade

p/l(i) = Vi(Ci + Di(X - Ni)T/S) 
where,
Di - direction of ith leg s.t. if long (Buy) D=(+1), if short (Sell) D=(-1)
Vi - Volume of ith leg in 1000's (1000 is smallest trade increment)
Ci - Round-Trip Commissions on ith leg (assumed ~$0.18 per 1000 in volume R/T)
X  - Exit price p/l is calculated for (same for all legs on PingPong exit)
Ni - Entry price of ith leg
T  - value of one Tick (smallest price increment quoted). This is in terms of account currency. Per 1000 in volume.
S  - decimal Size of one tick
--------------------------------------------------- cont'd -------------------------------------
To calculate minimum required volume on last leg of PingPong exit that will yield B/E, or better, calculate as follows:

If P/L (calculated above) is negative, call this quantity A (for adverse)
Let:
L denote absolute value of deLta in price between zone boundary and exit target. On last leg, as price 
breaks through zone boundary, trade in the direction of breakout 
(if upper zone boundary is penetrated, Buy. Otherwise, if lower zone boundary is penetrated, Sell)
so, the number of ticks between the particular zone boundary and the target beyond it is:
Number of ticks in L: (L/S) 

The minimum required volume (excluding commissions on the last leg) to at least break even at target is therefore:
V1 = Ceiling(A*S/L*T) give in 1000's

In actuality, the last leg also carries commission costs that need to be included in the break even analysis:
Let Q = V1*C, where C is commissions per 1000 volume R/T

Therefore, volume of last leg to break even or better:
V = Ceiling((A+Q)*S/(L*T))*1000
 */

using System;
using System.Linq;
using cAlgo.API;
using cAlgo.API.Indicators;
using cAlgo.API.Internals;
using cAlgo.Indicators;

namespace cAlgo
{
    [Robot(TimeZone = TimeZones.UTC, AccessRights = AccessRights.None)]
    public class Roni_cBot_Prod : Robot
    {
        ////13/08/2015 - changed pips to ticks
        //// Parameters Optimized to highest net profit per equity draw down, tupples 
        //[Parameter("Initial Target Pips", DefaultValue = 2)]
        //// 4 // 4 // 4 // 62
        //public int initTargetPips { get; set; }
        [Parameter("Initial Target Ticks", DefaultValue = 27)]
        public int initTargetTicks { get; set; }

        [Parameter("Symetric Half Zone Pips", DefaultValue = 1025)]
        // 48// 42// 43// 132
        public int halfZoneTicks { get; set; }

        [Parameter("Symetric Targets Beyond Zone Pips", DefaultValue = 600)]
        // 48// 47// 41// 32
        public int targetBeyondZoneTicks { get; set; }

        //[Parameter()]
        //public DataSeries SourceSeries { get; set; }


        [Parameter(DefaultValue = 1.19)]
        public double profitFactor { get; set; }

        //private MovingAverage slowMa;
        //private MovingAverage fastMa;

        private const string label = "Roni_cBot_Prod";

        //private bool pingPongActivated = false;
        double lowerZoneBoundry = 0.0;
        //declare & initialize zone variables
        double upperZoneBoundry = 0.0;
        double upperTarget = 0.0;
        double lowerTarget = 0.0;
        double factor = 0.0;

        double T = 0.0;
        //value of a tick in this pair in acct. currency
        double S = 0.0;
        //Tick size this currency

        private Position[] allPositions = new Position[0];

        private bool firstRun = true;
        //array of positions 
        //Position[] longPositions;
        //to hold long positions
        //Position[] shortPositions;
        //to hold short positions
        protected override void OnStart()
        {
            Positions.Closed += PositionsOnClosed;
            Positions.Opened += PositionsOnOpened;
            T = Symbol.TickValue;
            //doesn't change
            S = Symbol.TickSize;
            factor = Symbol.PipSize / Symbol.TickSize;
            //factor multiplier in converting target in ticks to compare position P/L in Pips
            //fastMa = Indicators.MovingAverage(SourceSeries, FastPeriods, MovingAverageType.Simple);
            //slowMa = Indicators.MovingAverage(SourceSeries, SlowMAPeriods, MovingAverageType.Simple);
            //UpdatePositionsArray();
            ////PrintAllPositions(allPositions);
        }

        protected override void OnTick()
        {
            if (firstRun)
            {
                Print("hello from firstRun");
                Print("Tick Value={0}, TickSize/Point={1}, PipValue={2}, PipSize={3}", T, S, Symbol.PipValue, Symbol.PipSize);
                CloseAllPositionsThisBotAndSymbol();
                firstRun = false;
            }
            UpdatePositionsArray();
            //should not return null
            if (allPositions == null)
                Print("WTF!");
            if (allPositions != null && allPositions.Length == 0)
            {
                //if no open position, seek entry
                //pingPongActivated = false;
                //if no positions yet, then pingpong exit is off
                CheckForEntry();
                //if only one position
            }
            else if (allPositions != null && allPositions.Length > 0)
            {
                //pingPongActivated = true;
                PingPongExit();
            }

        }
        //OnTick()

        private void PositionsOnClosed(PositionClosedEventArgs args)
        {
            Print("Hello from PositionsOnClosed()");
            var position = args.Position;
            //Print("Position closed with {0} profit", position.GrossProfit);

            UpdatePositionsArray();

            PrintAllPositions(allPositions);
        }
        private void PositionsOnOpened(PositionOpenedEventArgs args)
        {
            Print("Hello from PositionsOnOpened()");
            UpdatePositionsArray();
            PrintAllPositions(allPositions);
            //Print("Position opened {0}", args.Position.Label);
        }

        private void PingPongExit()
        {
            //Print("Hello from PingPongExit()");
            UpdatePositionsArray();
            int numberOfPositions = allPositions.Length;
            //Print("hello from pingpong numberOfPositions = {0}", numberOfPositions);
            //is first leg always first in the array?
            if (numberOfPositions > 0 && allPositions[0].Comment != "1st")
            {
                Print("Position ID {0} is first in allpositions array but not first leg!", allPositions[0].Id);
            }
            //if only 1st leg, calculate zone levels
            if (numberOfPositions == 1 && allPositions[0].Comment == "1st")
            {
                //zone not set...set it
                if (lowerZoneBoundry == 0.0)
                {
                    //calculate zone and targets based on initial entry
                    lowerZoneBoundry = allPositions[0].EntryPrice - halfZoneTicks * Symbol.TickSize;
                    upperZoneBoundry = allPositions[0].EntryPrice + halfZoneTicks * Symbol.TickSize;
                    upperTarget = upperZoneBoundry + targetBeyondZoneTicks * Symbol.TickSize;
                    lowerTarget = lowerZoneBoundry - targetBeyondZoneTicks * Symbol.TickSize;
                    //factor = Symbol.PipSize / Symbol.TickSize;
                }

                //if 1st leg reached initial target, close it
                if (allPositions[0].Pips * factor >= initTargetTicks)
                {
                    //13/08 changed pips to ticks
                    Print("hello from close of 1st leg section of pingpong");
                    CloseAllPositionsThisBotAndSymbol();
                }
                //if (allPositions[0].Pips >= initTargetPips)
                //{
                //    Print("hello from close of 1st leg section of pingpong");
                //    CloseAllPositionsThisBotAndSymbol();
                //}
            }


            //if price moves beyond upper zone boundry - rebalance for b/e or better on the upper target (ask price)
            //else if price moves beyond lower zone boundry - rebalance for b/e or better on the lower target (bid)
            if (Symbol.Ask >= upperZoneBoundry)
            {
                //Print("hello from above upperZoneBoundry of pingpong");
                //re-balace positions to break-even or better on upperTarget
                long vol = GetVolumeToBrkEvn(GetPLatTarget(upperTarget), targetBeyondZoneTicks);
                //Print("vol returned = {0}", vol);
                if (vol > 0)
                {
                    var tr = ExecuteMarketOrder(TradeType.Buy, Symbol, vol, label, null, null, null, "not 1st");
                    Print("traded from pingpong: {0}", tr.Position.TradeType.ToString() + ": " + tr.Position.Volume.ToString());
                }

            }
            if (Symbol.Bid <= lowerZoneBoundry)
            {
                //Print("hello from below lowerZoneBoundry of pingpong");
                //re-balace positions to break-even or better on upperTarget
                long vol = GetVolumeToBrkEvn(GetPLatTarget(lowerTarget), targetBeyondZoneTicks);
                //Print("vol returned = {0}", vol);
                if (vol > 0)
                {
                    var tr = ExecuteMarketOrder(TradeType.Sell, Symbol, vol, label, null, null, null, "not 1st");
                    Print("traded from pingpong: {0}", tr.Position.TradeType.ToString() + ": " + tr.Position.Volume.ToString());
                }
            }
            //update positions array
            UpdatePositionsArray();

            //is last position at target?
            if (Symbol.Bid >= upperTarget || Symbol.Ask <= lowerTarget)
            {
                Print("before close all");
                PrintAllPositions(allPositions);
                CloseAllPositionsThisBotAndSymbol();
                Print("after close all");
                PrintAllPositions(allPositions);
            }
            return;
        }
        //PingPongExit()

        private void CloseAllPositionsThisBotAndSymbol()
        {
            //Print("hello from CloseAllPositionsThisBotAndSymbol()");
            UpdatePositionsArray();
            foreach (var pos in allPositions)
            {
                TradeResult tr = ClosePosition(pos);
                //ClosePositionAsync(pos);
                Print(tr.ToString());
            }
            UpdatePositionsArray();
            ZeroZoneVariables();
        }

        private void ZeroZoneVariables()
        {
            //Print("hello from ZeroZoneVariables()");
            lowerZoneBoundry = 0.0;
            upperZoneBoundry = 0.0;
            upperTarget = 0.0;
            lowerTarget = 0.0;
        }


        private double GetPLatTarget(double priceTarget)
        {
            //Print("hello from GetPLatTarget()");
            //this method calculates sum of profit loss from all open positions including commissions at target price
            double plSum = 0.0;
            /*
            p/l(i) = Vi(Ci + Di(X - Ni)T/S) 
            where,
            Di - direction of ith leg s.t. if long (Buy) D=(+1), if short (Sell) D=(-1)
            Vi - Volume of ith leg in 1000's (1000 is smallest trade increment)
            Ci - Round-Trip Commissions on ith leg (assumed ~$0.18 per 1000 in volume R/T)
            X  - Exit price p/l is calculated for (same for all legs on PingPong exit)
            Ni - Entry price of ith leg
            T  - value of one Tick (smallest price increment quoted). This is in terms of account currency. Per 1000 in volume.
            S  - decimal Size of one tick
            */
                        /*//new code - causes null ref. exception?
            foreach (var pos in allPositions)
            {
                double vi = pos.Volume;
                double ci = pos.Commissions * 2.0;//func. returns one-way, ci is R/T
                double di = pos.TradeType == TradeType.Buy ? 1.0 : -1.0; //if not Buy, assume is Sell, may need to revise as cAlgo product develops
                double x  = priceTarget;
                double ni = pos.EntryPrice;
                double pl = vi * (ci + ((di * T*(x - ni))  / S)); //does not include swap
                plSum += pl;
            }
            Print("GetPLatTarget(): plSum = {0}", plSum);
            return plSum;
            */

            //this is prev. version of code that worked OK, it included swap costs
foreach (var pos in allPositions)
            {
                double pips2target = pos.TradeType == TradeType.Buy ? (priceTarget - pos.EntryPrice) / Symbol.PipSize : (pos.EntryPrice - priceTarget) / Symbol.PipSize;

                double posPL = pips2target * pos.Volume * Symbol.PipValue + pos.Commissions + pos.Swap;
                //are commission and swap values reported (-) vlaues?
                plSum += posPL;

                ////string s = "GetPLatTarget(): \n" + "pips2target= " + pips2target.ToString() + "\n" + "allPositions.Length = " + allPositions.Length.ToString() + "\n" + "Position: ID:" + pos.Id.ToString() + ", " + pos.TradeType.ToString() + ", vol:" + pos.Volume.ToString() + "\n" + "Pos. Com.: " + pos.Commissions + "\n" + "Pip value: " + Symbol.PipValue + "\n" + "Pos. P/L at Target: " + posPL.ToString() + "\n" + "Pos's P/L Sum: " + plSum.ToString();
                //Print(s);
            }
            //Print("GetPLatTarget(): plSum = {0}", plSum);
            return plSum;

        }

        private long GetVolumeToBrkEvn(double pl, int ticksToTarget)
        {
            //Print("hello from GetVolumeToBrkEvn()");
            //this method return required volume to break even or better at price target including commissions (excluding swap), considering mininimum trade volume increments
            //where pl is P/L to overcome, and 
            //pipsToTarget is number of pips from zone extereme to exit target
            if (pl >= 0.0)
                return 0L;
            // if not adverse, no rebalancing required
            double vol = -1 * pl / (ticksToTarget * Symbol.TickValue);
            // vol in 1000's (neg. P/L => neg. lots, need to be made positive)
            vol = Math.Ceiling(vol / 1000);
            //in 1000's
            //lots of 1000 rounded up (pos.)
            pl = pl - vol * 0.18;
            //P/L updated with commissions: $0.09 each direction per 1000 assumed
            //lots = Math.Ceiling((-1 * pl / (pipsToTarget * Symbol.PipValue)) / 1000);
            vol = Math.Ceiling((-1 * pl / (ticksToTarget * Symbol.TickValue)) * profitFactor / 1000);
            //profitFactor is added edge where: 1.0 is no added edge, 1.10 is 10% etc.
            //Print("hello from GetVolumeToBrkEvn: {0}", s);
            return (long)(vol * 1000.0);
            // Symbol.NormalizeVolume(lots, RoundingMode.Up);
        }

        //entry rules
        //reached here if no positions open
        private void CheckForEntry()
        {
            //Print("hello from CheckForEntry()");
            //enter random
            Random r = new Random((int)DateTime.Now.Ticks & 0xffff);

            int dir = r.Next(-2, 2);
            TradeResult tr;
            if (dir >= 0)
            {
                tr = ExecuteMarketOrder(TradeType.Buy, Symbol, 1000, label, null, null, null, "1st");

                Print("1st buy entry {0}", tr.Position.TradeType.ToString());
            }
            else if (dir < 0)
            {
                tr = ExecuteMarketOrder(TradeType.Sell, Symbol, 1000, label, null, null, null, "1st");
                Print("1st sell entry {0}", tr.Position.TradeType.ToString());
            }
            else
                return;
        }
        //CheckForEntry()



        private void UpdatePositionsArray()
        {
            //Print("hello from UpdatePositionsArray()");
            allPositions = Positions.FindAll(label, Symbol);
            if (allPositions == null)
                allPositions = new Position[0];
            //to prevent returning null reference
            // PrintAllPositions(allPositions);
        }

        private void PrintAllPositions(Position[] ap)
        {
            Print("hello from PrintAllPositions()");
            //Print("ap.len=",ap.Length);
            //if (ap.Length>0)
            //{
            foreach (var pos in ap)
            {
                Print(pos.Id, ", ", pos.TradeType, ", ", pos.Volume, ", ", pos.Label, ", ", pos.Comment);
                Print("-----------------------------------------");
            }
            Print("at end of PrintAllPositions()");
            //}
        }


    }
    //class ModifiedcBotRoni
}
//namespace cAlgo
