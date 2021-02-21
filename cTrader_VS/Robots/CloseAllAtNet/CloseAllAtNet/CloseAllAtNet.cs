using System;
using System.Linq;
using cAlgo.API;
using cAlgo.API.Indicators;
using cAlgo.API.Internals;
using cAlgo.Indicators;

namespace cAlgo
{
    [Robot(TimeZone = TimeZones.UTC, AccessRights = AccessRights.None)]
    public class CloseAllAtNet : Robot
    {
        [Parameter(DefaultValue = 0.25)]
        public double NetToKillAllPositions { get; set; }

        [Parameter(DefaultValue = "-")]
        public string label { get; set; }

        protected override void OnStart()
        {
            Print("{0} started", label);
        }

        protected override void OnTick()
        {
            // Put your core logic here
            if (GetTotalNet() >= NetToKillAllPositions)
                FlattenAll(label, Symbol);
        }

        private void FlattenAll(string lbl, Symbol symbl)
        {
            var psns = Positions.FindAll(lbl, symbl);
            foreach (var pos in psns)
            {
                ClosePositionAsync(pos, OnClosedAsyncCallback);
            }
        }

        private void OnClosedAsyncCallback(TradeResult tr)
        {
            if (tr.IsSuccessful)
                Print(tr.ToString());
            else
                Print("Error in closing occured, error: {0}", tr.Error);
        }

        private double GetTotalNet()
        {
            var psns = Positions.FindAll(label, Symbol);
            double totNet = 0.0;
            foreach (var pos in psns)
            {
                totNet += pos.NetProfit;
            }
            return totNet;
        }

        protected override void OnStop()
        {
            // Put your deinitialization logic here
        }
    }
}
