using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using cAlgo;
using cAlgo.API;
using cAlgo.API.Indicators;
using cAlgo.API.Internals;
using cAlgo.Indicators;
using System.Diagnostics.Contracts;

namespace cAlgo
{
    class SortedPositions
    {
        //props
        public MultiStage3 cBot { get; set; }
        public string Symbol { get; set; }
        public List<Position> CompositePositions { get; set; }
        public List<Position> LongPositions { get; set; }
        public List<Position> ShortPositions { get; set; }
        //volume weighed average entry price long positions in LongPositions list
        private double volWdEntryPrcLong;
        public double VolWdEntryPrcLong
        {
            get { return volWdEntryPrcLong; }
            private set { volWdEntryPrcLong = value; }
        }
        //volume weighed average entry price short positions in ShortPositions list
        private double volWdEntryPrcShort;
        public double VolWdEntryPrcShort
        {
            get { return volWdEntryPrcShort; }
            private set { volWdEntryPrcShort = value; }
        }
        //total long exposure volume in LongPositions list 
        private long longExposureVol;

        public long LongExposureVol
        {
            get { return longExposureVol; }
            private set { longExposureVol = value; }
        }

        //total short exposure volume in ShortPositions list
        private long shortExposureVol;

        public long ShortExposureVol
        {
            get { return shortExposureVol; }
            private set { shortExposureVol = value; }
        }

        //c'tor
        public SortedPositions(List<Position> compositePositions, MultiStage3 cBot)
        {//requires all positions in composite list to be of same symbol
            Contract.Requires<ArgumentNullException>(compositePositions != null);
            this.CompositePositions = compositePositions;
            this.cBot = cBot;
            this.Symbol = null;
            this.LongPositions = new List<Position>();
            this.ShortPositions = new List<Position>();
            this.ShortExposureVol = 0L;
            this.LongExposureVol = 0L;
            UpdateAll();   
        }
        //c'tor overload
        public SortedPositions(String symbol, MultiStage3 cBot)
        {//for use in dictionary making class, allows use of AddPosition() to incrementally build, 
            //and calling UpdateAll() when done
            this.cBot = cBot;
            this.Symbol = symbol;
            this.CompositePositions = null; //to be built in UpdateAll()
            this.LongPositions = new List<Position>();
            this.ShortPositions = new List<Position>();
            this.ShortExposureVol = 0L;
            this.LongExposureVol = 0L;
        }

        internal void AddPosition(Position pos)
        {//build position collections incrementally
            if (pos.TradeType == TradeType.Buy)
            {
                LongPositions.Add(pos);
            }
            else
            {
                ShortPositions.Add(pos);
            }
        }

        internal void UpdateAll()
        {

            foreach (var pos in CompositePositions)
            {
                //in case CompositePositions is null such as when building via AddPosition()
                if (CompositePositions == null) CompositePositions = 
                        (List<Position>)ShortPositions.Concat(LongPositions);

                //all positions in compositePositions list should be of same symbol
                if (this.Symbol == null)
                {
                    this.Symbol = pos.SymbolCode;
                }
                if (this.Symbol != pos.SymbolCode) throw 
                        new InvalidOperationException("symbol mismatch in compositePos. list");
                //add pos to approp. list, sum vol & avg. prc.
                if(pos.TradeType==TradeType.Buy)
                {
                    LongPositions.Add(pos);
                    LongExposureVol += pos.Volume;
                    VolWdEntryPrcLong += pos.EntryPrice * (double)pos.Volume;
                }
                else
                {
                    ShortPositions.Add(pos);
                    ShortExposureVol += pos.Volume;
                    VolWdEntryPrcShort += pos.EntryPrice * (double)pos.Volume;
                }
            //foreach
            }
            VolWdEntryPrcLong /= LongExposureVol;
            VolWdEntryPrcShort /= ShortExposureVol;
        //UpdateAll()
        }

        //internal void AddPos(Position pos)
        //{
        //    throw new NotImplementedException();
        //}
        // SortedPositions
    }

}
