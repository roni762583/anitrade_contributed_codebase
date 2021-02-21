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
    public class NewScalper : Robot
    {
        [Parameter(DefaultValue = 30.0)]
        public double TpTicks { get; set; }

        [Parameter(DefaultValue = 50)]
        public double HdgTicks { get; set; }

        string label = "NewScalper";
        double f;//factor to convert pips to ticks
        List<Tuple<Position, Position>> stl; //special hedged positions tuple list
        TradeType dir; //direction of last hedge
        List<Position> specialPositionsList;
        bool brk = false;

        protected override void OnStart()
        {
            //register events
            Positions.Closed += PositionsOnClosed;
            // factor for converting pips to ticks
            specialPositionsList = new List<Position>();
            f = (Symbol.PipSize / Symbol.TickSize);
            stl = new List<Tuple<Position, Position>>();
            dir = TradeType.Buy; //arbitrary direction to start scalping in 
        }

        private void PositionsOnClosed(PositionClosedEventArgs args)
        {
            var pos = args.Position;
            specialPositionsList.Remove(pos); //remove position from list if there
            Print("Position closed with {0} comment", pos.Comment);
        }

        protected override void OnTick()
        {
            //if price is near special hedged position pair, unlist tuple from special
            UnlistSpecialPosNearPriceAction();

            //Loop over open positions, to close or hedge positions as appropriate
            foreach (var pos in Positions.FindAll(label, Symbol))
            {
                //if any non-special position at t/p, close it out
                if (pos.Pips * f >= TpTicks && !GetSpecialPosIdList().Contains(pos.Id))
                {
                    ClosePositionAsync(pos, OnCloseAsync);
                }

                //if any non-special position is in red hedge ticks, hedge opposite
                if (!GetSpecialPosIdList().Contains(pos.Id) && pos.Pips * f <= -HdgTicks)
                {
                    dir = pos.TradeType == TradeType.Buy ? TradeType.Sell : TradeType.Buy; //get hdg direction
                    TradeOperation hto = ExecuteMarketOrderAsync(dir, Symbol, pos.Volume, label, 0.0, 0.0, null,
                        "special", OnExecuted); //hdg

                    //add the hedged positions to the special list
                    specialPositionsList.Add(pos);
                 
                }//if
            }//foreach-loop over positions

            //if no open positions (not counting special hedges), open in direction of last hedg
            if (GetOpenPosIdList().Except(GetSpecialPosIdList()).Count() == 0)
            {
                ExecuteMarketOrderAsync(dir, Symbol, GetVolume(), label, 0.0, 0.0, null, "1st", OnExecuted);
            }
        }//OnTick()

        private void OnCloseAsync(TradeResult tr)
        {
            Print("Pos. {0} {1} closed async",tr.Position.Id,tr.Position.TradeType);
        }

        private List<int> GetOpenPosIdList()
        {
            return Positions.FindAll(label, Symbol).Select(p => p.Id).ToList();
        }
        
        private List<int> GetSpecialPosIdList()
        {
            var spl = new List<int>();
            foreach (var pos in specialPositionsList)
            {
                spl.Add(pos.Id);
            }
            return spl;
        }
        
        private void UnlistSpecialPosNearPriceAction()
        {
            specialPositionsList.RemoveAll(p => p.Pips * f > -HdgTicks);
        }

        private long GetVolume()
        {
            return 1000L;
        }

        private void OnExecuted(TradeResult result)
        {
            if (result.IsSuccessful)
            {
                specialPositionsList.Add(result.Position);
                Print("{0} {1} comt:{2}", result.Position.Id, result.Position.TradeType, result.Position.Comment);
            }
            else
            {
                Print("Failed to create position");
            }
        }

        protected override void OnStop() {}
    }
}
