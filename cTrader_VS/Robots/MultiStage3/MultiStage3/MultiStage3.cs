// Multistage 3, is based on Long_Scalper_cBot, but uses Parabolic SAR indicator. 
// if net p/l is negative on PSAR exit signal, pass the position to ping pong exit for management
// so that new position can be opened by PSAR
// should be combined with directional movement, i.e. if sideways, there is no point to hedging

//need to fix money management and safety features such as:
//-maximal losses switch, 
//-maximal hedge size,
//-money management to calculate car25 and Bandy recommended risk metrics for determining next trade size
//based on moneys allocated to this robot as pctg. of account equity (calc. what portion the bot is already using)

//winding down open positions for shut down
//don't enter new trades before w/e break at least average trade sequence in duration

//handling open positions after server restart (write/read to file)
//posibilities for shut down:
//server crash
//manual shut down for maint. or other reason
//w/e break
//software/broker error
//
//as such, if this is an initial start, there would not be a data file present, 
//build the file based on current positions if any
//
//-if data file is present, check each open position for asigned exit strategy in file
//if exit strategy==initial exit strategy (entry strategy), check if conditions exist to change to another exit strategy
//
//-if any positions that exist in file, but are no longer open, 
//check their status and comments in history and alert findings
//
//-if any open positions are not listed in data file, add them with asigned exit strategy
//
// !!! validate and make the data file system work so no label or comment is used at all, and 15 or more 
// strategies can run in parallel on same pair and timeframe, without conflict by keeping track of which position
// belongs to which sequence and strategy


//-add ability to change exit strategy from outside while running live 
//(same for parameters, in file)

//re-write ping pong from scratch, it loses money on multi-leg sequences

//tick price aggregation to be done inside robot to allow PnF chart

//add money management similar to LngSclp_MM until CAR25 is ready. 
//Also, have to MM look at market depth in the direction of trade to 
//make sure there is a taker for the order. Build mechanism to split 
//large orders piecemeal against available market depth

//add maximum daily losing amount, alert

//build system to log all alerts with maximum file size (clear out old entries)

//20151124 crashed file not found exception: data file - did file cleaning kill it or something??
//add alert of last few log entries in OnStop()
//
//add a text file with field that manually turn off running strategies, prevent new positions

using cAlgo;
using cAlgo.API;
using cAlgo.API.Indicators;
using cAlgo.API.Internals;
using cAlgo.Indicators;

using System;
using System.Linq;
using System.Threading;
using System.Data;
using System.IO;
using System.Text;
using System.Globalization;
using System.Reflection;

namespace cAlgo
{
    [Robot(TimeZone = TimeZones.UTC, AccessRights = AccessRights.FullAccess)]
    public class MultiStage3 : Robot
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


        //only used if initial volume set to zero
        [Parameter("Money Mgmt. Risk Estimate (decimal)", DefaultValue = 0.5)]
        public double mmRisk { get; set; }

        [Parameter("minAF", DefaultValue = 0.002)]
        public double minAF { get; set; }

        [Parameter("maxAF", DefaultValue = 0.02)]
        public double maxAF { get; set; }


        //props and fields
        internal const string label = "011100100110111101111001";
        // = roy

        public string Label
        {
            //later to add a unique identifier to label to create a unique instance id to 
            //allow multiple instances running on same pair and time frame
            get { return label; }
        }

        double lowerZoneBoundry = 0.0;
        double upperZoneBoundry = 0.0;
        double upperTarget = 0.0;
        double lowerTarget = 0.0;
        double factor;
        //value and size of a tick for this pair
        double T, S;

        internal Position[] allPositions = new Position[0];

        internal bool firstRun = true;

        internal ParabolicSAR psar;

        //positions data ops obj. contains table and file ops objcts
        internal DataOps dataOps;

        //strategies collection
        Strategy[] strGs;

        protected override void OnStart()
        {

            dataOps = new DataOps(this);
            dataOps.Reconcile();

            //events registration
            Positions.Closed += PositionsOnClosed;
            Positions.Opened += PositionsOnOpened;

            //constants
            T = Symbol.TickValue;
            S = Symbol.TickSize;
            //factor multiplier in converting target in ticks to compare position P/L in Pips
            factor = Symbol.PipSize / S;

            //indicators
            psar = Indicators.ParabolicSAR(minAF, maxAF);

            //strategies
            strGs = new Strategy[2];
            Print("b4 psar");
            var psr = new PsarStrategy(this);
            SendAlert("OnStart()");
            var ping = new PingPongStrategy(this);


            strGs[0] = psr;
            strGs[1] = ping;
        }

        protected override void OnTick()
        {
            //
            if (firstRun)
            {
                firstRun = false;
            }

            CheckStrategies();

            //check for exit conditions
            //CheckForExitConditions();

            //check for entry conditions
            //CheckForEntryConditions();

        }
        /*
        UpdatePositionsArray();


        if (allPositions != null && allPositions.Length == 0)
        {
            //if no open position, seek entry
            CheckForEntry();
        }
        else if (allPositions != null && allPositions.Length > 0)
        {
            CheckForExit();
        }
        */
        //OnTick()

        private void CheckStrategies()
        {
            foreach (var strategy in strGs)
            {
                strategy.Check();
            }
        }

        //private void CheckForExitConditions()
        //{
        ////get unique list of assigned exit strategies
        //var activeExits = dataOps.pdto.GetActiveExitsFromTable(dataOps.pdto.pdt);

        ////have each of activeExits check their positions
        //foreach (var ext in activeExits)
        //{
        //    //Get the method information using the method info class
        //    //MethodInfo mi = this.GetType().GetMethod(ext);
        //    //Invoke the method (null- no parameter for the method call, or you can pass the array of parameters...)
        //    //mi.Invoke(this, null);

        //}
        //}

        //private void CheckForEntryConditions()
        //{
        //    throw new NotImplementedException();
        //}

        internal void SendAlert(string msg)
        {
            Print("Alert:\n" + msg);
            Notifications.SendEmail("8053141tradealerts@gmai.com", "8053141tradealerts@gmai.com", "MultiStage3 Alert!", msg);
        }

        //internal void CheckForExit()
        //{
        //    if (allPositions != null && allPositions.Length > 0)
        //        PingPongExit();
        //}
        //CheckForExit()
        internal void PositionsOnClosed(PositionClosedEventArgs args)
        {
            //var position = args.Position;
            UpdatePositionsArray();
            //in Even Gvirol TLV Aroma after WATEC 15/10/2015

            dataOps.Reconcile();
        }

        internal void PositionsOnOpened(PositionOpenedEventArgs args)
        {
            UpdatePositionsArray();
            dataOps.Reconcile();
            // PositionsOnOpened()
        }

        //internal void PingPongExit()
        //{
        //    UpdatePositionsArray();

        //    int numberOfPositions = allPositions.Length;

        //    //if only 1 position exists...
        //    if (numberOfPositions == 1 && allPositions[0].Comment == "1st")
        //    {
        //        //zone not set...set it
        //        if (lowerZoneBoundry == 0.0)
        //        {
        //            //calculate zone and targets based on initial entry
        //            lowerZoneBoundry = allPositions[0].EntryPrice - halfZoneTicks * Symbol.TickSize;
        //            upperZoneBoundry = allPositions[0].EntryPrice + halfZoneTicks * Symbol.TickSize;
        //            upperTarget = upperZoneBoundry + targetBeyondZoneTicks * Symbol.TickSize;
        //            lowerTarget = lowerZoneBoundry - targetBeyondZoneTicks * Symbol.TickSize;
        //        }

        //        double tradeDir = allPositions[0].TradeType == TradeType.Buy ? 1.0 : -1.0;
        //        double sig = 0.0;
        //        // lrfpsar.Signal.LastValue;
        //        //if indicator in direction of trade, return
        //        if ((tradeDir > 0 && sig > 0) || (tradeDir < 0 && sig < 0))
        //        {

        //            return;
        //            //if opposing, it will check t/p below
        //        }
        //        //if 1st leg reached initial target, close it
        //        if (allPositions[0].Pips * factor >= initTargetTicks)
        //        {

        //            CloseAllPositionsThisBotAndSymbol();
        //        }
        //    }

        //    //if price moves beyond upper zone boundry - rebalance for b/e (or better by profit factor parameter) on the upper target (ask price)
        //    //else if price moves beyond lower zone boundry - rebalance for b/e or better on the lower target (bid)
        //    if (Symbol.Ask >= upperZoneBoundry)
        //    {
        //        long vol = GetVolumeToBrkEvn(GetPLatTarget(upperTarget), targetBeyondZoneTicks);

        //        if (vol > 0)
        //        {
        //            var tr = ExecuteMarketOrder(TradeType.Buy, Symbol, vol, label, null, null, null, "not 1st");
        //        }
        //    }

        //    if (Symbol.Bid <= lowerZoneBoundry)
        //    {
        //        long vol = GetVolumeToBrkEvn(GetPLatTarget(lowerTarget), targetBeyondZoneTicks);
        //        if (vol > 0)
        //        {
        //            var tr = ExecuteMarketOrder(TradeType.Sell, Symbol, vol, label, null, null, null, "not 1st");
        //        }
        //    }

        //    UpdatePositionsArray();

        //    // if price at either upper, or lower targets; close all legs
        //    if (Symbol.Bid >= upperTarget || Symbol.Ask <= lowerTarget)
        //    {
        //        CloseAllPositionsThisBotAndSymbol();
        //    }
        //    return;
        //    // PingPongExit()
        //}


        internal void CloseAllPositionsThisBotAndSymbol()
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


        internal void ZeroZoneVariables()
        {
            lowerZoneBoundry = 0.0;
            upperZoneBoundry = 0.0;
            upperTarget = 0.0;
            lowerTarget = 0.0;
            // ZeroZoneVariables()
        }


        internal double GetPLatTarget(double priceTarget)
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
            //Print("GetPLatTarget(): plSum = {0}", plSum);
            return plSum;
            // GetPLatTarget()
        }


        internal long GetVolumeToBrkEvn(double pl, int ticksToTarget)
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
        internal void CheckForEntry()
        {
            // get expert recommendtion for direction of trade
            double d = 1.0;
            // lrfpsar.Signal.LastValue;
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

        internal void EnterLong()
        {
            long vol = GetVolume();
            var tr = ExecuteMarketOrder(TradeType.Buy, Symbol, vol, label, null, null, null, "1st");
            //DisplayAlert("EnterLong()", vol.ToString(),"", "", "");
        }

        internal void EnterShort()
        {
            long vol = GetVolume();
            var tr = ExecuteMarketOrder(TradeType.Sell, Symbol, vol, label, null, null, null, "1st");
            //SetTradeVars(tr);
        }

        internal long GetVolume()
        {
            return initialVolume == 0 ? GetMMvol() : (long)initialVolume;
            //might ad code validating volume returned in increments of 1000 only
        }

        internal long GetMMvol()
        {
            double m = Account.FreeMargin * mmRisk;
            //mmRisk represents portion of free margin to be considered
            int f = Math.Max((int)(m / 1000.0), 1);
            //1000 will be min. volume
            long v = (long)f * 1000;
            //for every additional $1000 in portion of free margin, 1000 additional volume allocated
            return v;
        }

        internal void UpdatePositionsArray()
        {
            allPositions = Positions.FindAll(label, Symbol);
            if (allPositions == null)
                allPositions = new Position[0];
        }
        // UpdatePositionsArray()

        internal void PrintAllPositions(Position[] ap)
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

        protected override void OnStop()
        {
            SendAlert("OnStop()");
        }
    }
    // class 
}
// namespace
