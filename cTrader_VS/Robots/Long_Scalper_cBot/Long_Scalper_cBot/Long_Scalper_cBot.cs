using System;
using System.Linq;
using cAlgo.API;
using cAlgo.API.Indicators;
using cAlgo.API.Internals;
using cAlgo.Indicators;

namespace cAlgo
{
    [Robot(TimeZone = TimeZones.UTC, AccessRights = AccessRights.None)]
    public class Long_Scalper_cBot : Robot
    {
        [Parameter("Initial Target Ticks", DefaultValue = 25)]
        public int initTargetTicks { get; set; }

        [Parameter("Symetric Half Zone Pips", DefaultValue = 400)]
        public int halfZoneTicks { get; set; }

        [Parameter("Symetric Targets Beyond Zone Pips", DefaultValue = 400)]
        public int targetBeyondZoneTicks { get; set; }

        [Parameter(DefaultValue = 1.0)]
        public double profitFactor { get; set; }

        [Parameter(DefaultValue = 1000)]
        public int initialVolume { get; set; }

        private const string label = "Long_Scalper_cBot";

        double lowerZoneBoundry = 0.0;
        double upperZoneBoundry = 0.0;
        double upperTarget = 0.0;
        double lowerTarget = 0.0;
        double factor = 0.0;
        //value of a tick in this pair in acct. currency
        double T = 0.0;
        //Tick size this currency
        double S = 0.0;

        private Position[] allPositions = new Position[0];

        private bool firstRun = true;

        protected override void OnStart()
        {
            //events registration
            Positions.Closed += PositionsOnClosed;
            Positions.Opened += PositionsOnOpened;
            T = Symbol.TickValue;
            S = Symbol.TickSize;
            //factor multiplier in converting target in ticks to compare position P/L in Pips
            factor = Symbol.PipSize / Symbol.TickSize;
            // OnStart()
        }


        protected override void OnTick()
        {
            if (firstRun)
            {

                firstRun = false;
            }

            UpdatePositionsArray();

            if (allPositions != null && allPositions.Length == 0)
            {
                //if no open position, seek entry
                CheckForEntry();
            }
            else if (allPositions != null && allPositions.Length > 0)
            {
                PingPongExit();
            }
            //OnTick()
        }


        private void PositionsOnClosed(PositionClosedEventArgs args)
        {
            //var position = args.Position;
            UpdatePositionsArray();
            // PositionsOnClosed()
        }


        private void PositionsOnOpened(PositionOpenedEventArgs args)
        {
            UpdatePositionsArray();
            // PositionsOnOpened()
        }


        private void PingPongExit()
        {
            UpdatePositionsArray();

            int numberOfPositions = allPositions.Length;

            //if (numberOfPositions > 0 && allPositions[0].Comment != "1st")
            //{
            //    Print("Position ID {0} is first in allpositions array but not first leg!", allPositions[0].Id);
            //}
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
                }

                //if 1st leg reached initial target, close it
                if (allPositions[0].Pips * factor >= initTargetTicks)
                {
                    CloseAllPositionsThisBotAndSymbol();
                }
            }

            //if price moves beyond upper zone boundry - rebalance for b/e (or better by profit factor parameter) on the upper target (ask price)
            //else if price moves beyond lower zone boundry - rebalance for b/e or better on the lower target (bid)
            if (Symbol.Ask >= upperZoneBoundry)
            {
                long vol = GetVolumeToBrkEvn(GetPLatTarget(upperTarget), targetBeyondZoneTicks);

                if (vol > 0)
                {
                    var tr = ExecuteMarketOrder(TradeType.Buy, Symbol, vol, label, null, null, null, "not 1st");
                }
            }

            if (Symbol.Bid <= lowerZoneBoundry)
            {
                long vol = GetVolumeToBrkEvn(GetPLatTarget(lowerTarget), targetBeyondZoneTicks);
                if (vol > 0)
                {
                    var tr = ExecuteMarketOrder(TradeType.Sell, Symbol, vol, label, null, null, null, "not 1st");
                }
            }

            UpdatePositionsArray();

            // if price at either upper, or lower targets; close all legs
            if (Symbol.Bid >= upperTarget || Symbol.Ask <= lowerTarget)
            {
                CloseAllPositionsThisBotAndSymbol();
            }
            return;
            // PingPongExit()
        }


        private void CloseAllPositionsThisBotAndSymbol()
        {
            UpdatePositionsArray();

            foreach (var pos in allPositions)
            {
                TradeResult tr = ClosePosition(pos);
            }

            UpdatePositionsArray();

            ZeroZoneVariables();
            // CloseAllPositionsThisBotAndSymbol()
        }


        private void ZeroZoneVariables()
        {
            lowerZoneBoundry = 0.0;
            upperZoneBoundry = 0.0;
            upperTarget = 0.0;
            lowerTarget = 0.0;
            // ZeroZoneVariables()
        }


        private double GetPLatTarget(double priceTarget)
        {
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
                //commission values are returned as (-) vlaues

                plSum += posPL;
            }
            Print("GetPLatTarget(): plSum = {0}", plSum);
            return plSum;
            // GetPLatTarget()
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
            // GetVolumeToBrkEvn()
        }


        //entry rules...reached here if no positions open
        private void CheckForEntry()
        {
            long vol = (long)initialVolume;

            ExecuteMarketOrder(TradeType.Buy, Symbol, vol, label, null, null, null, "1st");

            return;
            //CheckForEntry()
        }


        private void UpdatePositionsArray()
        {
            allPositions = Positions.FindAll(label, Symbol);
            if (allPositions == null)
                allPositions = new Position[0];
            // UpdatePositionsArray()
        }


        private void PrintAllPositions(Position[] ap)
        {
            Print("hello from PrintAllPositions()");
            foreach (var pos in ap)
            {
                Print(pos.Id, ", ", pos.TradeType, ", ", pos.Volume, ", ", pos.Label, ", ", pos.Comment);
                Print("-----------------------------------------");
            }
            Print("at end of PrintAllPositions()");
            // PrintAllPositions()
        }

        // class
    }
// namespace
}
