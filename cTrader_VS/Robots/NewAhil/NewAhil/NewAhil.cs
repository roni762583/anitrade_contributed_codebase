using System;
using System.Linq;
using cAlgo.API;
using cAlgo.API.Indicators;
using cAlgo.API.Internals;
using cAlgo.Indicators;

namespace cAlgo
{
    [Robot(TimeZone = TimeZones.UTC, AccessRights = AccessRights.None)]
    public class NewAhil : Robot
    {
        [Parameter(DefaultValue = 100)]
        public int lookBack { get; set; }

        private IndicatorDataSeries _bid, _ask;

        //flag indicating building of time series is still ongoing
        bool buildingBidAskTS = true;

        int counter = 0;

        CircularQ<double> _bidQ;

        protected override void OnStart()
        {
            // Put your initialization logic here
            _bid = CreateDataSeries();
            //_bid[0] = 0.0; //get first value in there so when accessesing via count-1, don't get out of bounds exception on 0-1=-1 index
            _ask = CreateDataSeries();
            //_ask[0] = 0.0; //same reason

            _bidQ = new CircularQ<double>(lookBack);
        }

        protected override void OnTick()
        {
            
            if (buildingBidAskTS)
            {
                
                _bidQ.Enqueue(Symbol.Bid);
                Print("Q size={0}", _bidQ.Count);
                if (_bidQ.Count == lookBack) buildingBidAskTS = false;


                //_bid[counter] = Symbol.Bid;
                //_ask[counter] = Symbol.Ask;
                //counter++;
                //if (counter > lookBack) buildingBidAskTS = false;


            }
        }

        protected override void OnStop()
        {
            // Put your deinitialization logic here
            //for (int i = 0; i < _bid.Count; i++)
            //{
            //    string s = string.Format("Bid: {0} ,   Ask: {1}", _bid[i], _ask[i]);
            //    Print(s);
            //}
            string s = "";
            while (_bidQ.Count>0)
            {
                s+=_bidQ.Dequeue().ToString()+" ,  ";
            }
            Print("bids: {0}", s);
            
        }
    }
}
