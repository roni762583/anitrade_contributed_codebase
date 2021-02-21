using System;
using System.Linq;
using cAlgo.API;
using cAlgo.API.Indicators;
using cAlgo.API.Internals;
using cAlgo.Indicators;

namespace cAlgo
{
    [Robot(TimeZone = TimeZones.UTC, AccessRights = AccessRights.None)]
    public class EnterOnAroonExitOnChandelier : Robot
    {
       
        [Parameter(DefaultValue = 25)]
        public int aroonPeriod { get; set; }
        
        private Aroon ar;
        private IndicatorDataSeries 
        
        string label = "254";

        protected override void OnStart()
        {
            ar = Indicators.Aroon(aroonPeriod);
            Positions.Opened += PositionsOnOpened;
            Positions.Closed += PositionsOnClosed;
        }

        private void PositionsOnOpened(PositionOpenedEventArgs args)
        {
            var pos = args.Position;
            lastPositionOpenTime = pos.EntryTime;
            //string txt = "OnOpened()";
            //SendNotificationEmail(pos, txt);
        }

        private void PositionsOnClosed(PositionClosedEventArgs args)
        {
            var pos = args.Position;
            //string txt = "OnClosed(), {0}, P/L" + pos.NetProfit.ToString();
            //SendNotificationEmail(pos, txt);
        }


        protected override void OnTick()
        {
        }
        protected override void OnBar()
        { 
        }

        private void CloseAllPositions()
        {
            foreach (var pos in Positions.FindAll(label, Symbol))
            {
                ClosePositionAsync(pos);
            }
        }

        protected override void OnStop()
        {
            // Put your deinitialization logic here
        }
    }
}
