using System;
using System.Linq;
using cAlgo.API;
using cAlgo.API.Indicators;
using cAlgo.API.Internals;
using cAlgo.Indicators;

namespace cAlgo
{
    [Robot(TimeZone = TimeZones.UTC, AccessRights = AccessRights.None)]
    public class Ahil : Robot
    {
        [Parameter(DefaultValue = 22)]
        public int lookbackPeriods { get; set; }

        [Parameter(DefaultValue = 3)]
        public double atrMultiplier { get; set; }

        [Parameter(DefaultValue = 1000)]
        public double initialVolume { get; set; }

        [Parameter(DefaultValue = 0.5)]
        public double mmRisk { get; set; }

        //var for custom ind.
        private ChandelierSignal cs;

        private const string label = "Ahil";

        private TradeType lastTradeDirection;

        //flag to mark initial run from restart
        bool firstRun = true;
        bool firstRun2 = true;
        double firstSignal = 0, prevSignal = 0;

        protected override void OnStart()
        {
            cs = Indicators.GetIndicator<ChandelierSignal>(lookbackPeriods, atrMultiplier);
        }

        protected override void OnTick()
        {
            //this is to prevent initial trade from entering mid-state (not on initial signal event)
            if (firstRun2)
            {
                //set initial  entry signal
                firstSignal = cs.EntrySignal.LastValue;
                firstRun2 = false;
                //...and never come back
            }

            if (firstRun)
            {
                //if nothin' changed, return
                if (firstSignal == cs.EntrySignal.LastValue)
                {
                    return;
                }
                else
                {
                    //on new signal, set flag to never return
                    firstRun = false;
                    if (Flat())
                        CheckForEntry();
                    //don't wast first tick of signal, check for entry
                }
            }

            if (Flat())
                CheckForEntry();
            else
                CheckForExit();

            return;
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

        private void CheckForEntry()
        {
            double n = cs.EntrySignal.LastValue;
            double x = cs.ExitSignal.LastValue;
            var posArr = Positions.FindAll(label, Symbol);
            if (posArr != null)
            {
                if (n == 1 && x != -1 /*&& lastTradeDirection==TradeType.Sell*/)
                {
                    Print("long sig. @ {0}, n={1}, x={2}, pos={3}", Time.ToString(), n, x, posArr.Length);
                    EnterLong();
                    lastTradeDirection = TradeType.Buy;
                    return;
                }
                else if (n == -1 && x != 1 /*&& lastTradeDirection==TradeType.Buy*/)
                {
                    Print("shrt sig. @ {0}, n={1}, x={2}, pos={3}", Time.ToString(), n, x, posArr.Length);
                    EnterShort();
                    lastTradeDirection = TradeType.Sell;
                    return;
                }
            }
            return;
        }

        private void EnterShort()
        {
            long vol = GetVolume();
            ExecuteMarketOrder(TradeType.Sell, Symbol, vol, label, null, null, null, "");
            //just for testing

        }

        private void EnterLong()
        {
            long vol = GetVolume();
            ExecuteMarketOrder(TradeType.Buy, Symbol, vol, label, null, null, null, "");
            //just for testing

        }

        private long GetVolume()
        {
            return initialVolume == 0 ? GetMMvol() : (long)initialVolume;
            //might ad code validating volume returned in increments of 1000 only
        }

        private void CheckForExit()
        {
            if (LongPos() && cs.ExitSignal.LastValue == -1)
            {
                CloseAllPositionsThisBotSymbol();
            }
            else if (ShortPos() && cs.ExitSignal.LastValue == 1)
            {
                CloseAllPositionsThisBotSymbol();
            }
            return;
        }

        private void CloseAllPositionsThisBotSymbol()
        {
            foreach (var pos in (Positions.FindAll(label, Symbol)))
            {
                ClosePosition(pos);
            }

        }

        private long GetMMvol()
        {

            double m = Account.FreeMargin * mmRisk;
            //mmRisk represents portion of free margin to be considered
            int f = Math.Max((int)(m / 1000.0), 1);
            //1000 will be min. volume
            long v = (long)f * 1000;
            //for every additional $1000 in portion of free margin, 1000 additional volume allocated
            return v;
        }

        private bool ShortPos()
        {
            //returns true if short position/s found
            var psns = Positions.FindAll(label, Symbol);
            foreach (var pos in psns)
            {
                if (pos.TradeType == TradeType.Sell)
                    return true;
            }
            return false;
        }

        private bool LongPos()
        {
            //returns true if long position/s found
            var psns = Positions.FindAll(label, Symbol);
            foreach (var pos in psns)
            {
                if (pos.TradeType == TradeType.Buy)
                    return true;
            }
            return false;
        }

        protected override void OnStop()
        {
            // Put your deinitialization logic here
        }
    }
}
